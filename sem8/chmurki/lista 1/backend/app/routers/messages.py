from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload

from app.config import POLL_DEFAULT_LIMIT
from app.db import get_db
from app.models import Media, Message
from app.schemas import MediaOut, MessageCreate, MessageOut

router = APIRouter(prefix="/api/messages", tags=["messages"])


def _to_media_out(media: Media | None) -> MediaOut | None:
    if media is None:
        return None
    return MediaOut(
        id=media.id,
        original_name=media.original_name,
        content_type=media.content_type,
        size=media.size,
        created_at=media.created_at,
        content_url=f"/api/media/{media.id}/content",
    )


def _to_message_out(message: Message) -> MessageOut:
    return MessageOut(
        id=message.id,
        nickname=message.nickname,
        text=message.text,
        created_at=message.created_at,
        media=_to_media_out(message.media),
    )


@router.get("", response_model=list[MessageOut])
def get_messages(
    after_id: int | None = Query(default=None, ge=0),
    limit: int = Query(default=POLL_DEFAULT_LIMIT, ge=1, le=200),
    db: Session = Depends(get_db),
):
    query = db.query(Message).options(joinedload(Message.media)).order_by(Message.id.asc())
    if after_id is not None:
        query = query.filter(Message.id > after_id)
    items = query.limit(limit).all()
    return [_to_message_out(item) for item in items]


@router.post("", response_model=MessageOut)
def post_message(payload: MessageCreate, db: Session = Depends(get_db)):
    trimmed_text = payload.text.strip()
    if not trimmed_text and payload.media_id is None:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    media = None
    if payload.media_id is not None:
        media = db.query(Media).filter(Media.id == payload.media_id).first()
        if media is None:
            raise HTTPException(status_code=404, detail="Media not found")

    message = Message(
        nickname=payload.nickname.strip(),
        text=trimmed_text,
        media_id=payload.media_id,
    )
    db.add(message)
    db.commit()
    db.refresh(message)

    if media is not None:
        message.media = media

    return _to_message_out(message)
