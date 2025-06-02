# availability-service/src/domain/entities/seat_reservation.py

from dataclasses import dataclass
from uuid import uuid4
from datetime import datetime
from typing import List, Dict, Any

@dataclass
class SeatReservation:
    reservation_id: str
    booking_id: str
    match_id: str
    seats: List[Dict[str, Any]]
    status: str
    reserved_at: datetime

    @staticmethod
    def create(booking_id: str,
               match_id: str,
               seats: List[Dict[str, Any]],
               status: str) -> "SeatReservation":
        return SeatReservation(
            reservation_id=str(uuid4()),
            booking_id=booking_id,
            match_id=match_id,
            seats=seats,
            status=status,
            reserved_at=datetime.utcnow()
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            "reservationId": self.reservation_id,
            "bookingId": self.booking_id,
            "matchId": self.match_id,
            "seats": self.seats,
            "status": self.status,
            "timestamp": self.reserved_at.isoformat()
        }
