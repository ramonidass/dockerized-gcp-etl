import tempfile
import os
import polars as pl
from app.utils.logger import logger
from app.loader.process_visits import process_visits


def bigquery_via_parquet(
    df: pl.DataFrame,
    bq_client,
    storage_client,
    bucket_name: str,
    staging_prefix: str,
    table_id: str,
    partition_field: str = None,
):
    df2 = df.with_columns(
        [
            pl.col("visit_date").cast(pl.Date),
            pl.col("original_reported_date").cast(pl.Date),
        ]
    )

    with tempfile.NamedTemporaryFile(suffix=".parquet", delete=False) as tmp_file:
        tmp_path = tmp_file.name
        df2.write_parquet(tmp_path)

    blob_name = f"{staging_prefix}/{os.path.basename(tmp_path)}"
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(tmp_path)
    gcs_uri = f"gs://{bucket_name}/{blob_name}"
    logger.info(f"Uploaded staging parquet to {gcs_uri}")

    job_config = bq_client.LoadJobConfig(
        source_format=storage_client.SourceFormat.PARQUET,
        write_disposition=bq_client.WriteDisposition.WRITE_APPEND,
        autodetect=False,
    )
    if partition_field:
        job_config.time_partitioning = bq_client.TimePartitioning(
            type_=bq_client.TimePartitioningType.DAY, field=partition_field
        )

    load_job = bq_client.load_table_from_uri(
        gcs_uri, table_id, job_config=job_config)
    load_job.result()
    logger.info(f"Loaded {df2.height} rows into {table_id}")


def ingest_visits(
    bq_client,
    storage_client,
    bucket_name: str,
    file_name: str,
    staging_prefix: str,
    valid_table_id: str,
    invalid_table_id: str,
    partition_field: str = "visit_date",
):
    try:
        df_valid, df_invalid = process_visits(
            bq_client, storage_client, bucket_name, file_name
        )

        if df_valid.height > 0:
            logger.info(f"Ingesting {df_valid.height} valid rows...")
            bigquery_via_parquet(
                df=df_valid,
                bq_client=bq_client,
                storage_client=storage_client,
                bucket_name=bucket_name,
                staging_prefix=staging_prefix,
                table_id=valid_table_id,
                partition_field=partition_field,
            )
        else:
            logger.warning("No valid rows to ingest.")

        if df_invalid.height > 0:
            logger.info(f"Ingesting {df_invalid.height} invalid rows...")
            bigquery_via_parquet(
                df=df_invalid,
                bq_client=bq_client,
                storage_client=storage_client,
                bucket_name=bucket_name,
                staging_prefix=staging_prefix,
                table_id=invalid_table_id,
                partition_field=None,
            )
        else:
            logger.info("No invalid rows to ingest.")

    except Exception as e:
        logger.error(f"Failed ingestion: {e}")
        raise
