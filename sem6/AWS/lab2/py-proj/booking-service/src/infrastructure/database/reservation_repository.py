import logging
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from ...infrastructure.config import settings

logger = logging.getLogger(__name__)

# 1) Stworzenie silnika i tabeli jeśli nie istnieje
engine = create_engine(settings.DATABASE_URL, echo=False)
with engine.begin() as conn:
    conn.execute(text("""
      CREATE TABLE IF NOT EXISTS reservations (
          id TEXT PRIMARY KEY,
          match_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          status TEXT NOT NULL
      )
      """))

SessionLocal = sessionmaker(bind=engine)

class ReservationRepository:
    def __init__(self):
        self.session = SessionLocal()

    def add(self, reservation):
        data = reservation.to_dict()
        logger.info(f"[Booking][DB] Inserting reservation: {data}")
        self.session.execute(
            text(
                "INSERT OR REPLACE INTO reservations (id, match_id, user_id, status) "
                "VALUES (:id, :match_id, :user_id, :status)"
            ),
            data
        )
        self.session.commit()

    def list_all(self):
        logger.info("[Booking][DB] Querying all reservations")
        rows = self.session.execute(text("SELECT id, match_id, user_id, status FROM reservations")).fetchall()
        # zamieniamy na listę dictów
        return [
            {"id": r.id, "match_id": r.match_id, "user_id": r.user_id, "status": r.status}
            for r in rows
        ]
