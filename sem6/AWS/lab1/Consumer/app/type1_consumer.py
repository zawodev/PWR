import logging
import argparse
from consumer_base import ConsumerBase
from Consumer.domain.events.type1_event import Type1Event

logger = logging.getLogger(__name__)

class Type1ConsumerA(ConsumerBase):
    def __init__(self):
        super().__init__(Type1Event)

    def process(self, event):
        logger.info("[Type1ConsumerA] Przetwarzam event: %s", event.data)

def main():
    logging.basicConfig(level=logging.INFO, format='[Type1ConsumerA] %(asctime)s %(name)s %(levelname)s: %(message)s')
    consumer = Type1ConsumerA()
    try:
        consumer.run()
    except KeyboardInterrupt:
        consumer.broker.close()

if __name__ == "__main__":
    main()
