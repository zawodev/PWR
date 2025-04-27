import logging
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from ...infrastructure.config import settings

logger = logging.getLogger(__name__)

# 1) Połączenie oraz utworzenie tabeli payments
engine = create_engine(settings.DATABASE_URL, echo=False)  # :contentReference[oaicite:0]{index=0}
with engine.begin() as conn:
    conn.execute(text("""
      CREATE TABLE IF NOT EXISTS payments (
          reservation_id TEXT PRIMARY KEY,
          succeeded INTEGER NOT NULL,
          amount INTEGER,
          failure_reason TEXT
      )
"""))  # :contentReference[oaicite:1]{index=1}

SessionLocal = sessionmaker(bind=engine)

class PaymentRepository:
    def __init__(self):
        self.session = SessionLocal()

    def add(self, reservation_id: str, succeeded: bool, amount: int, failure_reason: str):
        logger.info(f"[Payment] Saving payment: {reservation_id}, succeeded={succeeded}, amount={amount}, reason={failure_reason}")  # :contentReference[oaicite:2]{index=2}
        self.session.execute(
            text("INSERT OR REPLACE INTO payments (reservation_id, succeeded, amount, failure_reason) "
                 "VALUES (:reservation_id, :succeeded, :amount, :failure_reason)"),
            {
                "reservation_id": reservation_id,
                "succeeded": int(succeeded),
                "amount": amount,
                "failure_reason": failure_reason
            }
        )
        self.session.commit()  # :contentReference[oaicite:3]{index=3}
