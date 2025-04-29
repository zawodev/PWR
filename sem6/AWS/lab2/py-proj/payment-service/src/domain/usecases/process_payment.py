# payment-service/src/domain/usecases/process_payment.py

import random
from ...domain.entities.payment import Payment
from ...infrastructure.database.payment_repository import PaymentRepository

class ProcessPaymentUseCase:
    def __init__(self):
        self.repo = PaymentRepository()

    def execute(self, data: dict) -> Payment:
        succeeded = random.choice([True, True, False])
        failure_reason = None if succeeded else "InsufficientFunds"
        amount = round(random.uniform(10, 100), 2)

        payment = Payment.create(
            booking_id=data["bookingId"],
            amount=data.get("amount", amount),
            currency=data.get("currency", "PLN"),
            succeeded=succeeded,
            failure_reason=failure_reason
        )
        self.repo.add(payment)
        return payment
