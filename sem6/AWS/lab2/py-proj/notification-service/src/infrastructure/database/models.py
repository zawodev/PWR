from sqlalchemy import Column, String, JSON, Numeric
from sqlalchemy.ext.declarative import declarative_base
import uuid
from datetime import datetime

Base = declarative_base()

def now_iso():
    return datetime.utcnow().isoformat()

class Notification(Base):
    __tablename__ = "notifications"

    notification_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    ticket_id       = Column(String(36), nullable=False)
    user_id         = Column(String(36), nullable=False)
    channel         = Column(String(10), nullable=False)
    status          = Column(String(20), nullable=False)
    payload         = Column(JSON, nullable=False)
    sent_at         = Column(String, nullable=True)
    created_at      = Column(String, nullable=False, default=now_iso)
    updated_at      = Column(String, nullable=False, default=now_iso, onupdate=now_iso)
