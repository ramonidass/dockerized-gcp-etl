import json
import io
import polars as pl
from pydantic import ValidationError
from app.utils.schema import Visit
from app.utils.logger import logger


def visits_schema_validation(
    bq_client, storage_client, bucket_name: str, file_name: str
):
    try:
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        content = blob.download_as_bytes()

        valid_visits = []
        invalid_lines = []
        line_num = 0

        for line in io.StringIO(content.decode("utf-8")):
            line_num += 1
            try:
                json_data = json.loads(line.strip())
                visit = Visit(**json_data)
                valid_visits.append(visit.model_dump())
            except (json.JSONDecodeError, ValidationError) as e:
                logger.warning(f"[Line {line_num}] Validation failed: {e}")
                invalid_lines.append(
                    {"line_number": line_num, "raw_json": line.strip()}
                )

        df_valid = pl.DataFrame(valid_visits) if valid_visits else pl.DataFrame()
        df_invalid = pl.DataFrame(invalid_lines) if invalid_lines else pl.DataFrame()

        return df_valid, df_invalid

    except Exception as e:
        logger.error(f"Error processing file: {e}")
        raise
