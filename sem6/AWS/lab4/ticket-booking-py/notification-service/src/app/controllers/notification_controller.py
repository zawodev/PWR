import logging
from fastapi import APIRouter, HTTPException, status

from ...domain.queries.list_notifications_handler import handle_list_notifications

logger = logging.getLogger(__name__)
router = APIRouter()

@router.get(
    path="/",
    status_code=status.HTTP_200_OK,
    summary="List all notifications"
)
def list_notifications():
    logger.info("[Notification][API] GET /notifications")
    try:
        notifications = handle_list_notifications()
        return {"notifications": notifications}
    except Exception as e:
        logger.error(f"[Notification][API] Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
