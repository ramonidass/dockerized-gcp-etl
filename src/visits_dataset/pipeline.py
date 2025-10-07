from src.utils.logger import get_logger
import tempfile
import os
import json
import polars as pl
from google.cloud import bigquery
from src.visits.transform import visits_schema_validation


logger = get_logger(__name__)


def bigquery_via_jsonl(
    df: pl.DataFrame,
    bq_client,
    storage_client,
    bucket_name: str,
    staging_prefix: str,
    table_id: str,
    partition_field: str = None,
):
    df = df.with_columns(
        pl.col("visit_date").dt.strftime("%Y-%m-%d"),
        pl.col("original_reported_date").dt.strftime("%Y-%m-%d"),
    )

    records = df.to_dicts()

    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".jsonl", delete=False
    ) as tmp_file:
        tmp_path = tmp_file.name
        for record in records:
            tmp_file.write(json.dumps(record) + "\n")

    blob_name = f"{staging_prefix}/{os.path.basename(tmp_path)}"
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(tmp_path)
    gcs_uri = f"gs://{bucket_name}/{blob_name}"
    logger.info(f"Uploaded staging JSONL to {gcs_uri}")

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        autodetect=False,
    )
    if partition_field:
        job_config.time_partitioning = bigquery.TimePartitioning(
            type_=bigquery.TimePartitioningType.DAY, field=partition_field
        )

    load_job = bq_client.load_table_from_uri(gcs_uri, table_id, job_config=job_config)
    load_job.result()
    logger.info(f"Loaded {df.height} rows into {table_id}")


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
        df_valid, df_invalid = visits_schema_validation(
            bq_client, storage_client, bucket_name, file_name
        )

        if df_valid.height > 0:
            logger.info(f"Ingesting {df_valid.height} valid rows...")
            bigquery_via_jsonl(
                df=df_valid,
                bq_client=bq_client,
                storage_client=storage_client,
                bucket_name=bucket_name,
                staging_prefix=staging_prefix,
                table_id=valid_table_id,
                partition_field=partition_field,
            )
        else:
            logger.info("No valid rows to ingest.")

        if df_invalid.height > 0:
            logger.info(f"Ingesting {df_invalid.height} invalid rows...")
            bigquery_via_jsonl(
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

        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        processed_file_name = f"processed/{os.path.basename(file_name)}"
        bucket.rename_blob(blob, processed_file_name)
        logger.info(f"Moved processed file to {processed_file_name}")

    except Exception as e:
        logger.error(f"Failed ingestion: {e}")
        raise
