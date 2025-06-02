from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    RABBITMQ_URL: str
    RABBITMQ_EXCHANGE: str = "booking.events"
    BOOKING_SERVICE_URL: str = "http://localhost:8000"

    class Config:
        env_file = ".env"

settings = Settings()
