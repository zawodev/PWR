import logging
from ...infrastructure.database.notification_repository import NotificationRepository

logger = logging.getLogger(__name__)

def handle_list_notifications():
    logger.info("[Notification][QUERY] Listing all notifications")
    items = NotificationRepository().list_all()
    return [n.__dict__ for n in items]
