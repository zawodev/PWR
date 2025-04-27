from dataclasses import dataclass
from uuid import uuid4

@dataclass
class Reservation:
    id: str
    match_id: str
    user_id: str
    status: str

    @staticmethod
    def create(match_id: str, user_id: str):
        return Reservation(
            id=str(uuid4()),
            match_id=match_id,
            user_id=user_id,
            status="PENDING"
        )

    def to_dict(self):
        return {
            "id": self.id,
            "match_id": self.match_id,
            "user_id": self.user_id,
            "status": self.status
        }
