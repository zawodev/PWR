import logging
from ...domain.entities.notification import Notification
from ...infrastructure.database.notification_repository import NotificationRepository

logger = logging.getLogger(__name__)

class SendNotificationCommand:
    def __init__(self, ticket_id: str, user_id: str, channel: str, status: str, payload: dict):
        self.ticket_id = ticket_id
        self.user_id = user_id
        self.channel = channel
        self.status = status
        self.payload = payload

def handle_send_notification(cmd: SendNotificationCommand):
    logger.info(f"[Notification][CMD] Handling SendNotification: {cmd.__dict__}")
    notification = Notification.create(
        ticket_id=cmd.ticket_id,
        user_id=cmd.user_id,
        channel=cmd.channel,
        status=cmd.status,
        payload=cmd.payload
    )
    NotificationRepository().add(notification)
    return notification.to_dict()
