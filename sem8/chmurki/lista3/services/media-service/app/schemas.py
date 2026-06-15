from datetime import datetime

from pydantic import BaseModel


class MediaOut(BaseModel):
    id: str
    original_name: str
    content_type: str
    size: int
    created_at: datetime
    content_url: str
