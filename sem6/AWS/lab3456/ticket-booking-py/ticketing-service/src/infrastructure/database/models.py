from sqlalchemy import Column, String, JSON, Numeric
from sqlalchemy.ext.declarative import declarative_base
import uuid
from datetime import datetime

Base = declarative_base()

def now_iso():
    return datetime.utcnow().isoformat()

class Ticket(Base):
    __tablename__ = "tickets"

    ticket_id      = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    booking_id     = Column(String(36), nullable=False)
    qr_code        = Column(String, nullable=False)
    issued_at      = Column(String, nullable=False, default=now_iso)
    valid_until    = Column(String, nullable=False)
    extra_metadata = Column("metadata", JSON, nullable=True)
    created_at     = Column(String, nullable=False, default=now_iso)
    updated_at     = Column(String, nullable=False, default=now_iso, onupdate=now_iso)

