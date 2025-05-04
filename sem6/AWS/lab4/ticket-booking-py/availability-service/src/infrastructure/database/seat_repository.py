# availability-service/src/infrastructure/database/seat_repository.py

import logging
from uuid import UUID
from sqlalchemy.orm import Session
from ...infrastructure.database.session import SessionLocal
from ...infrastructure.database.models import SeatReservation as ORMSeat
from ...domain.entities.seat_reservation import SeatReservation
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

class SeatRepository:
    def __init__(self):
        self.session: Session = SessionLocal()

    def add(self, domain: SeatReservation):
        orm = ORMSeat(
            reservation_id=domain.reservation_id,   # teraz string
            booking_id=domain.booking_id,
            match_id=domain.match_id,
            seats=domain.seats,
            status=domain.status,
            reserved_at=domain.reserved_at.isoformat()
        )
        logger.info(f"[Availability][DB] Merging seat_reservation: {orm.__dict__}")
        self.session.merge(orm)
        self.session.commit()

    def list_reserved_seats(self, match_id: str) -> List[Dict[str, Any]]:
        rows = (
            self.session
            .query(ORMSeat)
            .filter(
                ORMSeat.match_id == match_id,
                ORMSeat.status == "RESERVED"
            )
            .all()
        )
        reserved = []
        for r in rows:
            reserved.extend(r.seats)
        return reserved

    def list_all(self):
        logger.info("[Availability][DB] Querying all seat_reservations")
        return self.session.query(ORMSeat).all()
