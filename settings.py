# settings.py

# 1. Correct the import and also import BaseSettings
from pydantic_settings import BaseSettings, SettingsConfigDict

# 2. Make your class inherit from BaseSettings


class Settings(BaseSettings):
    """
    Defines the application settings, loaded from a .env file.
    """

    # This line is correct! It tells Pydantic where to find the .env file.
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # These are the variables Pydantic will look for in your .env file
    bucket_name: str
    file_name: str
    staging_prefix: str
    valid_table_id: str
    invalid_table_id: str
    partition_field: str


# 3. Create the instance. Pydantic will automatically load the variables.
settings = Settings()
