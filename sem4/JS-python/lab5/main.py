import re
import sys
import logging

# DEFINITIONS:
# file - list of lines
# line - raw line of text from file
# log - parsed line of data in form of a dict

# KONFIGURACJA LOGOWANIA
logging.basicConfig(level=logging.DEBUG)  # Ustawienie poziomu podstawowego na DEBUG

# Utworzenie handlera dla poziomów DEBUG, INFO, WARNING (wyjście na stdout)
stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.setLevel(logging.DEBUG)
stdout_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
stdout_handler.setFormatter(stdout_formatter)
stdout_handler.addFilter(lambda record: record.levelno <= logging.WARNING)

# Utworzenie handlera dla poziomów ERROR, CRITICAL (wyjście na stderr)
stderr_handler = logging.StreamHandler(sys.stderr)
stderr_handler.setLevel(logging.ERROR)
stderr_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
stderr_handler.setFormatter(stderr_formatter)

# Dodanie handlerów do loggera
logger = logging.getLogger()
logger.addHandler(stdout_handler)
logger.addHandler(stderr_handler)

def parse_log_file(file):
    log_dicts = []
    for line in file:
        parsed_line = parse_log_line(line.strip())
        if parsed_line:
            log_dicts.append(parsed_line)
    return log_dicts


def parse_log_line(line: str): # 2a
    """
    Converts raw line of text into a data in a form of a dictionary
    :param line: raw line (str)
    :return: log in dictionary structure
    """
    # Dec 10 07:13:56 LabSZ sshd[24227]: Disconnecting: Too many authentication failures for root [preauth]
    log_pattern = r'^(?P<timestamp>\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(?P<hostname>\S+)\s+sshd\[(?P<pid>\d+)\]:\s+(?P<event>.+)$'
    match = re.match(log_pattern, line)
    if match:
        log_dict = match.groupdict()
        logging.debug(f"read {len(line)} bytes from log line")
        return log_dict
    else:
        return None


def get_ipv4s_from_log(log): # 2b
    ipv4_pattern = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
    return re.findall(ipv4_pattern, log['event'])


def get_user_from_log(log):
    user_patterns = [
        r'user\s+(\S+)',
        r'user=(\S+)'
    ]
    for pattern in user_patterns:
        match = re.search(pattern, log['event'])
        if match:
            return match.group(1)
    return None


def get_message_type(event_description):
    event_description = event_description.lower()
    phrases = ["accepted password for",
               "failed password for",
               "connection closed by",
               "invalid user",
               "authentication failure",
               "possible break-in attempt"]
    for phrase in phrases:
        if phrase in event_description:
            return phrase
    return "other"


if __name__ == '__main__':
    log_file = parse_log_file(sys.stdin)
    for log_line in log_file:
        ipv4s = get_ipv4s_from_log(log_line)
        user = get_user_from_log(log_line)
        message_type = get_message_type(log_line['event'])

        if message_type in ["accepted password for", "connection closed by"]:
            logging.info(message_type)
        elif message_type == "failed password for":
            logging.warning(message_type)
        elif message_type in ["authentication failure", "invalid user"]:
            logging.error(message_type)
        elif message_type == "possible break-in attempt":
            logging.critical(message_type)
        else:
            logging.debug("Other message type")
