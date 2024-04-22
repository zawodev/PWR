import re
import sys
import logging
import my_utils as mu
import log_analysis as la

# DEFINITIONS:
# file - list of lines
# line - raw line of text from file
# log - parsed line of data in form of a dict

# Konfiguracja loggera
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# Ustawienie formatu dla logów
formatter = logging.Formatter('%(asctime)s; %(levelname)s: %(message)s')

# Ustawienie handlera dla logów na stdout (poziomy DEBUG, INFO, WARNING)
stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.setLevel(logging.DEBUG)  # Poziom ustawiony na INFO
stdout_handler.setFormatter(formatter)
logger.addHandler(stdout_handler)

# Ustawienie handlera dla logów na stderr (poziomy ERROR, CRITICAL)
stderr_handler = logging.StreamHandler(sys.stderr)
stderr_handler.setLevel(logging.ERROR)  # Poziom ustawiony na ERROR
stderr_handler.setFormatter(formatter)
logger.addHandler(stderr_handler)

# Filtrowanie poziomów ERROR i CRITICAL dla stdout
class ErrorCriticalFilter(logging.Filter):
    def filter(self, record):
        return record.levelno < logging.ERROR  # Zwraca True dla poziomów niższych niż ERROR

stdout_handler.addFilter(ErrorCriticalFilter())  # Dodanie filtru do handlera stdout

# KONFIGURACJA LOGOWANIA
logging.basicConfig(level=logging.DEBUG)  # Ustawienie poziomu podstawowego na DEBUG

def parse_log_file(file):
    log_dicts = []
    for line in file:
        parsed_line = parse_log_line(line.strip())
        if parsed_line:
            log_dicts.append(parsed_line)
    return log_dicts


def parse_log_line(line: str):
    log_pattern = r'^(?P<timestamp>\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(?P<hostname>\S+)\s+sshd\[(?P<pid>\d+)\]:\s+(?P<event>.+)$'
    match = re.match(log_pattern, line)
    if match:
        log_dict = match.groupdict()
        log_dict['ipv4s'] = mu.get_ipv4s_from_log(log_dict)
        log_dict['username'] = mu.get_user_from_log(log_dict['event'])
        log_dict['msg_type'] = mu.get_message_type(log_dict['event'])
        # logging.debug(f"read {len(line)} bytes from log line")
        return log_dict
    else:
        return None


def test1():
    for log_line in log_file:
        message_type = log_line['msg_type']

        if message_type in ["accepted password for", "connection closed by"]:
            logging.info(message_type)
        elif message_type == "failed password for":
            logging.warning(message_type)
        elif message_type in ["authentication failure", "invalid user"]:
            logging.error(message_type)
        elif message_type == "possible break-in attempt":
            logging.critical(message_type)
        else:
            logging.debug("other message type")


if __name__ == '__main__':
    log_file = parse_log_file(sys.stdin)
    # test1()

    la.print_log_analysis(log_file)

