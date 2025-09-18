import json
from app.utils.logger import logger
from app.utils.gcp_clients import get_gcp_clients
from app.loader.ingest import ingest_visits
from settings import settings


def main(event, context):
    try:
        file_data = json.loads(event["data"])["message"]["data"]
        bucket_name = file_data["bucket"]
        file_name = file_data["name"]
        logger.info(f"Processing file: gs://{bucket_name}/{file_name}")

        bq_client, storage_client = get_gcp_clients()

        ingest_visits(
            bq_client=bq_client,
            storage_client=storage_client,
            bucket_name=settings.bucket_name,
            file_name=settings.file_name,
            staging_prefix=settings.staging_prefix,
            valid_table_id=settings.valid_table_id,
            invalid_table_id=settings.invalid_table_id,
            partition_field=settings.partition_field,
        )

    except Exception as e:
        logger.error(f"Error in ingest: {e}")
        raise


if __name__ == "__main__":
    main()
