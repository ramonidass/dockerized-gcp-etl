from pydatic_settings import SettingsConfigDict


class Settings:
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    bucket_name: str
    file_name: str
    staging_prefix: str
    valid_table_id: str
    invalid_table_id: str
    partition_field: str


settings = Settings()
