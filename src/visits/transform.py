from src.utils.logger import get_logger
import json
import io
import polars as pl
from pydantic import ValidationError
from src.visits.schema import Visit

logger = get_logger(__name__)


def visits_schema_validation(
    bq_client, storage_client, bucket_name: str, file_name: str
):
    try:
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        content = blob.download_as_bytes()

        valid_visits = []
        invalid_visits = []
        line_num = 0

        for line in io.StringIO(content.decode("utf-8")):
            line_num += 1
            json_data = None
            try:
                json_data = json.loads(line.strip())
                visit = Visit(**json_data)
                valid_visits.append(visit.model_dump())
            except ValidationError as e:
                logger.warning(f"[Line {line_num}] Validation failed: {e}")
                if json_data:
                    invalid_visits.append(json_data)
            except json.JSONDecodeError as e:
                logger.error(f"[Line {line_num}] JSON decode error: {e}")

        df_valid = pl.from_dicts(valid_visits) if valid_visits else pl.DataFrame()

        df_invalid = pl.from_dicts(invalid_visits) if invalid_visits else pl.DataFrame()

        return df_valid, df_invalid

    except Exception as e:
        logger.error(f"Error processing file: {e}")
        raise
