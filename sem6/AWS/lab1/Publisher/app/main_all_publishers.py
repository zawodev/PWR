import logging
import threading
import time
from type1_publisher import Type1Publisher
from type2_publisher import Type2Publisher
from type3_publisher import Type3Publisher

def main():
    logging.basicConfig(level=logging.INFO, format='[ALL-PUBLISHERS] %(asctime)s %(name)s %(levelname)s: %(message)s')

    pub1_1 = Type1Publisher(publisher_id=1, interval=2)
    pub1_2 = Type1Publisher(publisher_id=2, interval=2)
    pub1_3 = Type1Publisher(publisher_id=3, interval=2)
    pub2 = Type2Publisher()
    pub3 = Type3Publisher()

    t1 = threading.Thread(target=pub1_1.run, daemon=True)
    t2 = threading.Thread(target=pub1_2.run, daemon=True)
    t3 = threading.Thread(target=pub1_3.run, daemon=True)
    t4 = threading.Thread(target=pub2.run, daemon=True)
    t5 = threading.Thread(target=pub3.run, daemon=True)

    t1.start()
    t2.start()
    t3.start()
    t4.start()
    t5.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pub1_1.broker.close()
        pub1_2.broker.close()
        pub1_3.broker.close()
        pub2.broker.close()
        pub3.broker.close()
        print("stopped all pubslishers")

if __name__ == "__main__":
    main()
