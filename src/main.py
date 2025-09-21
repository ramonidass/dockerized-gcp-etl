from fastapi import FastAPI, Request, HTTPException
from src.utils.logger import get_logger
from src.utils.gcp_client import get_gcp_clients
from src.visits.pipeline import ingest_visits
from src.settings import settings

logger = get_logger(__name__)
app = FastAPI()


@app.post("/")
async def receive_event(request: Request):
    event_data = await request.json()
    logger.info(f"Received event: {event_data}")

    try:
        bucket_name = event_data.get("bucket")
        file_name = event_data.get("name")

        if not bucket_name or not file_name:
            raise ValueError("'bucket' or 'name' not found in GCS event payload.")

        if "processed/" in file_name:
            logger.info(f"Ignoring already processed file: {file_name}")
            return {"status": "ignored", "reason": "Already processed"}, 200

        if not file_name.endswith(".txt"):
            logger.info(f"Ignoring file {file_name} as it is not a .txt file.")
            return {"status": "ignored", "reason": "Not a .txt file"}, 200

        bq_client, storage_client = get_gcp_clients()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        if not blob.exists():
            logger.info(f"Ignoring event for non-existent file: {file_name}")
            return {"status": "ignored", "reason": "File not found"}, 200

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
        raise HTTPException(status_code=500, detail=str(e))
