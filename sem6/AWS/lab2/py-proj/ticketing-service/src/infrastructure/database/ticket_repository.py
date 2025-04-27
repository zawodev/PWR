import logging
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from ...infrastructure.config import settings

logger = logging.getLogger(__name__)

# 1) Połączenie i tabela tickets
engine = create_engine(settings.DATABASE_URL, echo=False)  # :contentReference[oaicite:6]{index=6}
with engine.begin() as conn:
    conn.execute(text("""
  CREATE TABLE IF NOT EXISTS tickets (
     reservation_id TEXT PRIMARY KEY,
     ticket_id TEXT,
     issued_at TEXT
)
"""))  # :contentReference[oaicite:7]{index=7}

SessionLocal = sessionmaker(bind=engine)

class TicketRepository:
    def __init__(self):
        self.session = SessionLocal()

    def add(self, reservation_id: str, ticket_id: str, issued_at: str):
        logger.info(f"[Ticketing] Saving ticket: {reservation_id}, ticket_id={ticket_id}")  # :contentReference[oaicite:8]{index=8}
        self.session.execute(
            text("INSERT OR REPLACE INTO tickets (reservation_id, ticket_id, issued_at) "
                 "VALUES (:reservation_id, :ticket_id, :issued_at)"),
            {"reservation_id": reservation_id, "ticket_id": ticket_id, "issued_at": issued_at}
        )
        self.session.commit()  # :contentReference[oaicite:9]{index=9}
