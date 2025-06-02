import logging
import random
from ...domain.entities.payment import Payment
from ...infrastructure.database.payment_repository import PaymentRepository
from ...infrastructure.event_bus.rabbitmq_producer import producer
from ...domain.events.payment_succeeded_event import PaymentSucceededEvent
from ...domain.events.payment_failed_event import PaymentFailedEvent

logger = logging.getLogger(__name__)

class ProcessPaymentCommand:
    def __init__(self, booking_id, amount, currency):
        self.booking_id = booking_id
        self.amount = amount
        self.currency = currency

def handle_process_payment(cmd: ProcessPaymentCommand):
    succeeded = random.choice([True, True, False])
    payment = Payment.create(
        booking_id=cmd.booking_id,
        amount=cmd.amount,
        currency=cmd.currency,
        succeeded=succeeded,
        failure_reason=None if succeeded else "InsufficientFunds"
    )
    PaymentRepository().add(payment)
    key = PaymentSucceededEvent.NAME if succeeded else PaymentFailedEvent.NAME
    producer.publish(routing_key=key, message=payment.to_dict())
    return payment.to_dict()
