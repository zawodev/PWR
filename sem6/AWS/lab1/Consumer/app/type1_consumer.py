import logging
import argparse
from consumer_base import ConsumerBase
from Consumer.domain.events.type1_event import Type1Event

logger = logging.getLogger(__name__)

class Type1Consumer(ConsumerBase):
    def __init__(self, name="Type1Consumer"):
        self.name = name
        super().__init__(Type1Event)

    def process(self, event):
        logger.info(f"[{self.name}] Przetwarzam event: %s", event.data)

def main():
    consumer = Type1Consumer()
    logging.basicConfig(level=logging.INFO, format=f'[{consumer.name}] %(asctime)s %(name)s %(levelname)s: %(message)s')
    try:
        consumer.run()
    except KeyboardInterrupt:
        consumer.broker.close()

if __name__ == "__main__":
    main()
