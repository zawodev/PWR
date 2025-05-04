from sqlalchemy import Column, String, JSON, Numeric
from sqlalchemy.ext.declarative import declarative_base
import uuid
from datetime import datetime

Base = declarative_base()

def now_iso():
    return datetime.utcnow().isoformat()

class BookingORM(Base):
    __tablename__ = "bookings"

    booking_id     = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id        = Column(String, nullable=False)
    match_id       = Column(String, nullable=False)
    seats          = Column(JSON, nullable=False)
    status         = Column(String(20), nullable=False)
    extra_metadata = Column("metadata", JSON, nullable=True)
    created_at     = Column(String, nullable=False, default=now_iso)
    updated_at     = Column(String, nullable=False, default=now_iso, onupdate=now_iso)
