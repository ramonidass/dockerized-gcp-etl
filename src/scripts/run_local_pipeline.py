from src.utils.logger import get_logger
from src.settings import settings
from src.utils.gcp_client import get_gcp_clients
from src.visits.pipeline import ingest_visits


logger = get_logger(__name__)


def local_ingestor():
    try:
        bucket_name = settings.bucket_name
        file_name = settings.file_name

        if not bucket_name or not file_name:
            raise ValueError("'bucket' or 'name' not found in GCS event payload.")

        if "processed/" in file_name:
            logger.info(f"Ignoring already processed file: {file_name}")
            return {"status": "ignored", "reason": "Already processed"}, 200

        if not file_name.endswith(".txt"):
            logger.info(f"Ignoring file {file_name} as it is not a .txt file.")
            return {"status": "ignored", "reason": "Not a .txt file"}, 200

        bq_client, storage_client = get_gcp_clients()

        ingest_visits(
            bq_client=bq_client,
            storage_client=storage_client,
            bucket_name=bucket_name,
            file_name=file_name,
            staging_prefix=settings.staging_prefix,
            valid_table_id=settings.valid_table_id,
            invalid_table_id=settings.invalid_table_id,
            partition_field=settings.partition_field,
        )

        return {"status": "success"}, 200

    except Exception as e:
        logger.error(f"Error processing event: {e}")


if __name__ == "__main__":
    local_ingestor()
