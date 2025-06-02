from sqlalchemy import Column, String, JSON, Numeric
from sqlalchemy.ext.declarative import declarative_base
import uuid
from datetime import datetime

Base = declarative_base()

def now_iso():
    return datetime.utcnow().isoformat()

class Payment(Base):
    __tablename__ = "payments"

    payment_id     = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    booking_id     = Column(String(36), nullable=False)
    amount         = Column(Numeric(10, 2), nullable=False)
    currency       = Column(String(3), nullable=False)
    status         = Column(String(20), nullable=False)
    failure_reason = Column(String, nullable=True)
    initiated_at   = Column(String, nullable=False, default=now_iso)
    completed_at   = Column(String, nullable=True)
    created_at     = Column(String, nullable=False, default=now_iso)
    updated_at     = Column(String, nullable=False, default=now_iso, onupdate=now_iso)
