# payment-service/src/domain/entities/payment.py

from dataclasses import dataclass
from uuid import uuid4
from datetime import datetime

@dataclass
class Payment:
    payment_id: str
    booking_id: str
    amount: float
    currency: str
    status: str
    failure_reason: str
    initiated_at: datetime
    completed_at: datetime

    @staticmethod
    def create(booking_id: str,
               amount: float,
               currency: str,
               succeeded: bool,
               failure_reason: str = None) -> "Payment":
        now = datetime.utcnow()
        return Payment(
            payment_id=str(uuid4()),
            booking_id=booking_id,
            amount=amount,
            currency=currency,
            status="SUCCEEDED" if succeeded else "FAILED",
            failure_reason=failure_reason,
            initiated_at=now,
            completed_at=now
        )

    def to_dict(self):
        return {
            "paymentId": self.payment_id,
            "bookingId": self.booking_id,
            "amount": self.amount,
            "currency": self.currency,
            "status": self.status,
            "failureReason": self.failure_reason,
            "timestamp": self.completed_at.isoformat()
        }
