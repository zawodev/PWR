from sqlalchemy import Column, String, JSON, Numeric
from sqlalchemy.ext.declarative import declarative_base
import uuid
from datetime import datetime

Base = declarative_base()

def now_iso():
    return datetime.utcnow().isoformat()

class SeatReservation(Base):
    __tablename__ = "seat_reservations"

    reservation_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    booking_id     = Column(String(36), nullable=False)
    match_id       = Column(String(36), nullable=False)
    seats          = Column(JSON, nullable=False)
    status         = Column(String(20), nullable=False)
    reserved_at    = Column(String, nullable=False, default=now_iso)
    released_at    = Column(String, nullable=True)
    created_at     = Column(String, nullable=False, default=now_iso)
    updated_at     = Column(String, nullable=False, default=now_iso, onupdate=now_iso)

