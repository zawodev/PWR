from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from ...infrastructure.config import settings

# Połączenie do DB
engine = create_engine(settings.DATABASE_URL, echo=False)

# Utworzenie tabeli, jeśli nie ma
with engine.begin() as conn:
    conn.execute(text("""
      CREATE TABLE IF NOT EXISTS reservations (
          id TEXT PRIMARY KEY,
          match_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          status TEXT NOT NULL
      )
    """))  # :contentReference[oaicite:3]{index=3}

SessionLocal = sessionmaker(bind=engine)

class ReservationRepository:
    def __init__(self):
        self.session = SessionLocal()

    def add(self, reservation):
        self.session.execute(
            text(
                "INSERT INTO reservations (id, match_id, user_id, status) "
                "VALUES (:id, :match_id, :user_id, :status)"
            ),
            reservation.to_dict()
        )
        self.session.commit()
