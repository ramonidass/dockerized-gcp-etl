from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    staging_prefix: str
    valid_table_id: str
    invalid_table_id: str
    partition_field: str


settings = Settings()
