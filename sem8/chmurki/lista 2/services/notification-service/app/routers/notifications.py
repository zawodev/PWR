from datetime import datetime, timezone
import json
import uuid

import boto3
from fastapi import APIRouter, Header, HTTPException, Query

from app.config import AWS_REGION, NOTIFICATION_SHARED_SECRET, SNS_TOPIC_ARN
from app.db import get_notifications_table
from app.schemas import NotificationCreate, NotificationOut

router = APIRouter(prefix="/api/notifications", tags=["notifications"])

sns_client = boto3.client("sns", region_name=AWS_REGION)


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _to_out(item: dict) -> NotificationOut:
    return NotificationOut(
        id=item["notification_id"],
        title=item["title"],
        message=item["message"],
        created_at=item["created_at"],
        chat_id=item.get("chat_id"),
        sender=item.get("sender"),
        recipient=item.get("recipient"),
        status=item.get("status", "sent"),
    )


@router.get("/health")
def health():
    return {"status": "ok"}


@router.post("", response_model=NotificationOut)
def create_notification(
    payload: NotificationCreate,
    x_notification_secret: str | None = Header(default=None, alias="X-Notification-Secret"),
):
    if NOTIFICATION_SHARED_SECRET:
        if not x_notification_secret or x_notification_secret != NOTIFICATION_SHARED_SECRET:
            raise HTTPException(status_code=401, detail="Invalid notification secret")

    if not SNS_TOPIC_ARN:
        raise HTTPException(status_code=503, detail="SNS topic is not configured")

    notification_id = uuid.uuid4().hex
    created_at = _utc_now()
    item = {
        "notification_id": notification_id,
        "title": payload.title,
        "message": payload.message,
        "created_at": created_at,
        "chat_id": payload.chat_id,
        "sender": payload.sender,
        "recipient": payload.recipient,
        "status": "sent",
    }

    message_body = json.dumps(item, ensure_ascii=True)

    try:
        sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=message_body, Subject=payload.title)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"SNS publish failed: {exc}") from exc

    table = get_notifications_table()
    table.put_item(Item=item)

    return _to_out(item)


@router.get("", response_model=list[NotificationOut])
def list_notifications(limit: int = Query(default=25, ge=1, le=100)):
    table = get_notifications_table()
    response = table.scan(Limit=limit)
    items = response.get("Items", []) if isinstance(response, dict) else []

    sorted_items = sorted(items, key=lambda item: item.get("created_at", ""), reverse=True)
    return [_to_out(item) for item in sorted_items]


@router.get("/{notification_id}", response_model=NotificationOut)
def get_notification(notification_id: str):
    table = get_notifications_table()
    response = table.get_item(Key={"notification_id": notification_id})
    item = response.get("Item") if isinstance(response, dict) else None
    if item is None:
        raise HTTPException(status_code=404, detail="Notification not found")

    return _to_out(item)
