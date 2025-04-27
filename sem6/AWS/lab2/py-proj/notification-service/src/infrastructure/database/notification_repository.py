import logging
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from ...infrastructure.config import settings
import json

logger = logging.getLogger(__name__)

# 1) Połączenie i tabela notifications
engine = create_engine(settings.DATABASE_URL, echo=False)  # :contentReference[oaicite:12]{index=12}
with engine.begin() as conn:
    conn.execute(text("""
      CREATE TABLE IF NOT EXISTS notifications (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       event TEXT,
       payload TEXT,
       created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
      """))  # :contentReference[oaicite:13]{index=13}

SessionLocal = sessionmaker(bind=engine)

class NotificationRepository:
    def __init__(self):
        self.session = SessionLocal()

    def add(self, event: str, payload: dict):
        logger.info(f"[Notification] Saving notification: {event} – {payload}")  # :contentReference[oaicite:14]{index=14}
        self.session.execute(
            text("INSERT INTO notifications (event, payload) VALUES (:event, :payload)"),
            {"event": event, "payload": json.dumps(payload)}
        )
        self.session.commit()  # :contentReference[oaicite:15]{index=15}
