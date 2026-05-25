from datetime import datetime

from pydantic import BaseModel, Field


class NotificationCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    message: str = Field(min_length=1, max_length=1000)
    chat_id: int | None = None
    sender: str | None = None
    recipient: str | None = None


class NotificationOut(BaseModel):
    id: str
    title: str
    message: str
    created_at: datetime
    chat_id: int | None = None
    sender: str | None = None
    recipient: str | None = None
    status: str
