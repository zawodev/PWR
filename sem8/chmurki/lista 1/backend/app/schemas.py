from datetime import datetime

from pydantic import BaseModel, Field


class MediaOut(BaseModel):
    id: int
    original_name: str
    content_type: str
    size: int
    created_at: datetime
    content_url: str

    model_config = {"from_attributes": True}


class MessageCreate(BaseModel):
    nickname: str = Field(min_length=1, max_length=40)
    text: str = Field(default="", max_length=2000)
    media_id: int | None = None


class MessageOut(BaseModel):
    id: int
    nickname: str
    text: str
    created_at: datetime
    media: MediaOut | None = None

    model_config = {"from_attributes": True}
