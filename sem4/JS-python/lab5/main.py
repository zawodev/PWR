import re
import sys

# DEFINITIONS:
# file - list of lines
# line - raw line of text from file
# log - parsed line of data in form of a dict


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
        return match.groupdict()
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
        print("=============")
        print(get_ipv4s_from_log(log_line))
        print(get_user_from_log(log_line))
        print(get_message_type(log_line['event']))
    print("=============")