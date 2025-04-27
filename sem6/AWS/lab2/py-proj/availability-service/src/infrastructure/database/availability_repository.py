# Przykład availability-service/src/infrastructure/database/seat_repository.py
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from ...infrastructure.config import settings
import logging

logger = logging.getLogger(__name__)

# 1) Utworzenie silnika i tabeli, jeśli nie istnieje
engine = create_engine(settings.DATABASE_URL, echo=False)  # :contentReference[oaicite:4]{index=4}
with engine.begin() as conn:
    conn.execute(text("""
        CREATE TABLE IF NOT EXISTS seat_allocations (
            reservation_id TEXT PRIMARY KEY,
            allocated INTEGER NOT NULL,
            seat_number TEXT
        )
    """))  # :contentReference[oaicite:5]{index=5}

SessionLocal = sessionmaker(bind=engine)

class SeatRepository:
    def __init__(self):
        self.session = SessionLocal()

    def add(self, reservation_id: str, allocated: bool, seat_number: str):
        logger.info(f"Saving seat allocation: {reservation_id}, allocated={allocated}, seat={seat_number}")
        self.session.execute(
            text("INSERT OR REPLACE INTO seat_allocations (reservation_id, allocated, seat_number) "
                 "VALUES (:reservation_id, :allocated, :seat_number)"),
            {"reservation_id": reservation_id, "allocated": int(allocated), "seat_number": seat_number}
        )
        self.session.commit()  # :contentReference[oaicite:6]{index=6}
