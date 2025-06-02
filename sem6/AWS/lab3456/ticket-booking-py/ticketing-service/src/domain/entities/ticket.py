# ticketing-service/src/domain/entities/ticket.py

from dataclasses import dataclass
from uuid import uuid4
from datetime import datetime, timedelta

@dataclass
class Ticket:
    ticket_id: str
    booking_id: str
    qr_code: str
    issued_at: datetime
    valid_until: datetime

    @staticmethod
    def create(booking_id: str,
               qr_code: str,
               valid_minutes: int = 120) -> "Ticket":
        now = datetime.utcnow()
        return Ticket(
            ticket_id=str(uuid4()),
            booking_id=booking_id,
            qr_code=qr_code,
            issued_at=now,
            valid_until=now + timedelta(minutes=valid_minutes)
        )

    def to_dict(self):
        return {
            "ticketId": self.ticket_id,
            "bookingId": self.booking_id,
            "qrCode": self.qr_code,
            "issuedAt": self.issued_at.isoformat(),
            "validUntil": self.valid_until.isoformat()
        }
