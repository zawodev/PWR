import time
import random
import logging
from publisher_base import PublisherBase
from Publisher.domain.events.type3_event import Type3Event

logger = logging.getLogger(__name__)

class Type3Publisher(PublisherBase):
    def __init__(self):
        super().__init__(Type3Event)

    def run(self):
        while True:
            data = "Type3 random data"
            self.publish(data)
            sleep_time = random.randint(2, 6)
            time.sleep(sleep_time)

def main():
    logging.basicConfig(level=logging.INFO, format='[Type3Publisher] %(asctime)s %(name)s %(levelname)s: %(message)s')
    pub = Type3Publisher()
    try:
        pub.run()
    except KeyboardInterrupt:
        pub.broker.close()
        print("Zatrzymano publishera Type3.")

if __name__ == "__main__":
    main()
