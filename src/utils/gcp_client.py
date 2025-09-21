from google.cloud import bigquery, storage
from src.utils.logger import get_logger

logger = get_logger(__name__)


def get_gcp_clients():
    try:
        bq_client = bigquery.Client()
        storage_client = storage.Client()
        logger.info("Initialized BigQuery and Storage clients")
        return bq_client, storage_client
    except Exception as e:
        logger.error(f"Failed to initialize GCP clients: {e}")
        raise
