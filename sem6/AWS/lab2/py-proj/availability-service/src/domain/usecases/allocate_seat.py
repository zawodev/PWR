import random
from ...domain.entities import *

class AllocateSeatUseCase:
    def execute(self, data: dict):
        # prosta losowa alokacja
        allocated = random.choice([True, True, True, False])
        return {
            "reservation_id": data["id"],
            "allocated": allocated,
            "seat_number": f"A{random.randint(1, 100)}" if allocated else None
        }
