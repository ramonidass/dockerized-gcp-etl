from fastapi import FastAPI, Request, HTTPException
from app.utils.logger import logger
from app.utils.gcp_client import get_gcp_clients
from app.loader.ingest import ingest_visits
from settings import settings


app = FastAPI()


@app.post("/")
async def receive_event(request: Request):
    event_data = await request.json()
    logger.info(f"Received event: {event_data}")

    try:
        subject = event_data.get("subject")
        if not subject:
            raise ValueError("CloudEvent 'subject' not found in payload.")

        parts = subject.split("/")
        bucket_name = parts[3]
        file_name = "/".join(parts[5:])

        logger.info(f"Processing file: gs://{bucket_name}/{file_name}")

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
        raise HTTPException(status_code=500, detail=str(e))
