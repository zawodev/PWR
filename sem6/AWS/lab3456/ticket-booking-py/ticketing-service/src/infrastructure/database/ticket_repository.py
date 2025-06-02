# ticketing-service/src/infrastructure/database/ticket_repository.py

import logging
from uuid import UUID
from sqlalchemy.orm import Session
from ...infrastructure.database.session import SessionLocal
from ...infrastructure.database.models import Ticket as ORMTicket
from ...domain.entities.ticket import Ticket

logger = logging.getLogger(__name__)

class TicketRepository:
    def __init__(self):
        self.session: Session = SessionLocal()

    def add(self, domain: Ticket):
        orm = ORMTicket(
            ticket_id=domain.ticket_id,
            booking_id=domain.booking_id,
            qr_code=domain.qr_code,
            issued_at=domain.issued_at.isoformat() if domain.issued_at else "",
            valid_until=domain.valid_until.isoformat() if domain.valid_until else ""
        )
        logger.info(f"[Ticketing][DB] Inserting ticket: {orm.__dict__}")
        self.session.merge(orm)
        self.session.commit()

    def list_all(self):
        logger.info("[Ticketing][DB] Querying all tickets")
        return self.session.query(ORMTicket).all()
