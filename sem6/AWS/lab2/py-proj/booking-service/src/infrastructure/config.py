from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    RABBITMQ_URL: str
    RABBITMQ_EXCHANGE: str = "booking.events"

    class Config:
        env_file = ".env"

settings = Settings()
