from dataclasses import dataclass, field
from uuid import uuid4
from datetime import datetime
from typing import List, Dict, Any

@dataclass
class Reservation:
    id: str
    user_id: str
    match_id: str
    seats: List[Dict[str, Any]]
    status: str
    metadata: Dict[str, Any]
    created_at: datetime

    @staticmethod
    def create(user_id: str,
               match_id: str,
               seats: List[Dict[str, Any]],
               metadata: Dict[str, Any] = None) -> "Reservation":
        return Reservation(
            id=str(uuid4()),
            user_id=user_id,
            match_id=match_id,
            seats=seats,
            status="PENDING",
            metadata=metadata or {},
            created_at=datetime.utcnow()
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            "bookingId": self.id,
            "userId": self.user_id,
            "matchId": self.match_id,
            "seats": self.seats,
            "metadata": self.metadata,
            "timestamp": self.created_at.isoformat()
        }
