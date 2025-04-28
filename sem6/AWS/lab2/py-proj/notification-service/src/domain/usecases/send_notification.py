# notification-service/src/domain/usecases/send_notification.py

from ...domain.entities.notification import Notification
from ...infrastructure.database.notification_repository import NotificationRepository

class SendNotificationUseCase:
    def __init__(self):
        self.repo = NotificationRepository()

    def execute(self, data: dict, channel: str, status: str) -> Notification:
        """
        data = event payload; channel/status zależne od typu eventu
        """
        notification = Notification.create(
            ticket_id=data.get("ticketId", data.get("bookingId", "")),
            user_id=data.get("userId", ""),
            channel=channel,
            status=status,
            payload=data
        )
        self.repo.add(notification)
        return notification
