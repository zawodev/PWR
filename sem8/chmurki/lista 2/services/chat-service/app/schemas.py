from datetime import datetime

from pydantic import BaseModel, Field


class ChatCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    slug: str | None = Field(default=None, max_length=80)


class ChatOut(BaseModel):
    id: int
    name: str
    slug: str
    created_at: datetime

    model_config = {"from_attributes": True}


class MediaOut(BaseModel):
    id: str
    original_name: str
    content_type: str
    size: int
    created_at: datetime
    content_url: str


class MessageCreate(BaseModel):
    nickname: str | None = Field(default=None, min_length=1, max_length=40)
    text: str = Field(default="", max_length=2000)
    media_id: str | None = None


class MessageOut(BaseModel):
    id: int
    chat_id: int
    nickname: str
    text: str
    created_at: datetime
    media: MediaOut | None = None

    model_config = {"from_attributes": True}
