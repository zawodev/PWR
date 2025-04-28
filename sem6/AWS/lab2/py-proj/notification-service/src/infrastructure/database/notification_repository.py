# notification-service/src/infrastructure/database/notification_repository.py

import logging
from uuid import UUID
from sqlalchemy.orm import Session
from ...infrastructure.database.session import SessionLocal
from ...infrastructure.database.models import Notification as ORMNotification
from ...domain.entities.notification import Notification

logger = logging.getLogger(__name__)

class NotificationRepository:
    def __init__(self):
        self.session: Session = SessionLocal()

    def add(self, domain: Notification):
        orm = ORMNotification(
            notification_id=domain.notification_id,
            ticket_id=domain.ticket_id,
            user_id=domain.user_id,
            channel=domain.channel,
            status=domain.status,
            payload=domain.payload,
            sent_at=domain.sent_at.isoformat() if domain.sent_at else ""
        )
        logger.info(f"[Notification][DB] Inserting notification: {orm.__dict__}")
        self.session.merge(orm)
        self.session.commit()

    def list_all(self):
        logger.info("[Notification][DB] Querying all notifications")
        return self.session.query(ORMNotification).all()
