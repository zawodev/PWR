import random

class ProcessPaymentUseCase:
    def execute(self, data: dict):
        # prosty losowy wynik płatności
        succeeded = random.choice([True, True, False])
        return {
            "reservation_id": data["reservation_id"],
            "succeeded": succeeded,
            "amount": data.get("amount", 100),  # przykład pola
            "failure_reason": None if succeeded else "InsufficientFunds"
        }
