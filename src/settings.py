from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    bucket_name: Optional[str] = None
    file_name: Optional[str] = None
    staging_prefix: str
    valid_table_id: str
    invalid_table_id: str
    partition_field: str


settings = Settings()
