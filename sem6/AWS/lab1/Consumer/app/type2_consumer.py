import logging
from consumer_base import ConsumerBase
from Consumer.domain.events.type2_event import Type2Event

logger = logging.getLogger(__name__)

class Type2Consumer(ConsumerBase):
    def __init__(self):
        super().__init__(Type2Event)

    def process(self, event):
        logger.info("[Type2Consumer] Przetwarzam event: %s", event.data)

def main():
    logging.basicConfig(level=logging.INFO, format='[Type2Consumer] %(asctime)s %(name)s %(levelname)s: %(message)s')
    consumer = Type2Consumer()
    try:
        consumer.run()
    except KeyboardInterrupt:
        consumer.broker.close()

if __name__ == "__main__":
    main()
