# payment-service/src/infrastructure/database/payment_repository.py

import logging
from uuid import UUID
from sqlalchemy.orm import Session
from ...infrastructure.database.session import SessionLocal
from ...infrastructure.database.models import Payment as ORMPayment
from ...domain.entities.payment import Payment

logger = logging.getLogger(__name__)

class PaymentRepository:
    def __init__(self):
        self.session: Session = SessionLocal()

    def add(self, domain: Payment):
        orm = ORMPayment(
            payment_id=domain.payment_id,
            booking_id=domain.booking_id,
            amount=domain.amount,
            currency=domain.currency,
            status=domain.status,
            failure_reason=domain.failure_reason,
            initiated_at=domain.initiated_at.isoformat() if domain.initiated_at else "",
            completed_at=domain.completed_at.isoformat() if domain.completed_at else ""
        )
        logger.info(f"[Payment][DB] Inserting payment: {orm.__dict__}")
        self.session.merge(orm)
        self.session.commit()

    def list_all(self):
        logger.info("[Payment][DB] Querying all payments")
        return self.session.query(ORMPayment).all()
