import logging
import time

class Logger:
    def __init__(self):
        self.start_time = time.time()
        logging.basicConfig(level=logging.INFO, format="%(message)s")
        self.logger = logging.getLogger("JourneyPlanner")

    def log(self, message: str):
        elapsed = time.time() - self.start_time
        self.logger.info(f"[{elapsed:.2f} s] {message}")
