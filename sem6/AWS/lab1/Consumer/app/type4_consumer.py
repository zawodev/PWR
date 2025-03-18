import logging
from consumer_base import ConsumerBase
from Consumer.domain.events.type4_event import Type4Event

logger = logging.getLogger(__name__)

class Type4Consumer(ConsumerBase):
    def __init__(self):
        super().__init__(Type4Event)

    def process(self, event):
        logger.info("[Type4Consumer] Otrzymałem event typu 4: %s", event.data)

def main():
    logging.basicConfig(level=logging.INFO, format='[Type4Consumer] %(asctime)s %(name)s %(levelname)s: %(message)s')
    consumer = Type4Consumer()
    try:
        consumer.run()
    except KeyboardInterrupt:
        consumer.broker.close()

if __name__ == "__main__":
    main()
