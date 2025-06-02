# notification-service/src/domain/entities/notification.py

from dataclasses import dataclass
from uuid import uuid4
from datetime import datetime
from typing import Dict, Any

@dataclass
class Notification:
    notification_id: str
    ticket_id: str
    user_id: str
    channel: str
    status: str
    payload: Dict[str, Any]
    sent_at: datetime

    @staticmethod
    def create(ticket_id: str,
               user_id: str,
               channel: str,
               status: str,
               payload: Dict[str, Any]) -> "Notification":
        return Notification(
            notification_id=str(uuid4()),
            ticket_id=ticket_id,
            user_id=user_id,
            channel=channel,
            status=status,
            payload=payload,
            sent_at=datetime.utcnow() if status == "SENT" else None
        )

    def to_dict(self):
        return {
            "notificationId": self.notification_id,
            "ticketId": self.ticket_id,
            "userId": self.user_id,
            "channel": self.channel,
            "status": self.status,
            "payload": self.payload,
            "sentAt": self.sent_at.isoformat() if self.sent_at else None
        }
