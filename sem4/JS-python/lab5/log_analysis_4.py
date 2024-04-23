import random
import datetime
import statistics
from collections import Counter


def get_random_logs_for_user(log_file, n=1, username=None): # a
    if username is None:
        all_users = set(log['username'] for log in log_file)
        if all_users:
            username = random.choice(list(all_users))
        else:
            return []

    user_logs = [log['line'] for log in log_file if log['username'] == username]
    return {'username': username, 'logs': random.sample(user_logs, min(n, len(user_logs)))}


def calculate_ssh_connection_stats(log_file): # b
    global_duration = []
    user_durations = {}

    def calculate_user_duration():
        duration = (prev_timestamp - start_time).total_seconds()
        global_duration.append(duration)
        user_durations.setdefault(prev_username, []).append(duration)

    _username = None
    start_time = None

    prev_timestamp = None
    prev_username = None
    prev_pid = None

    for log in log_file:
        timestamp = datetime.datetime.strptime(log['timestamp'], "%b %d %H:%M:%S").replace(year=2013)
        pid = log['pid']
        _username = log['username'] if log['username'] is not None else _username

        if prev_pid != pid:
            if start_time is not None and prev_timestamp is not None and prev_username is not None:
                calculate_user_duration()
            prev_pid = pid
            start_time = timestamp
        else:
            start_time = min(start_time, timestamp)
        prev_timestamp = timestamp
        prev_username = _username

    if start_time is not None:
        calculate_user_duration()

    global_avg_time = statistics.mean(global_duration)
    global_std_dev = statistics.stdev(global_duration) if len(global_duration) > 1 else 0

    user_stats = {}
    for _username, durations in user_durations.items():
        # print(f"{username} : {durations}") # for debug purposes
        user_avg_time = statistics.mean(durations)
        user_std_dev = statistics.stdev(durations) if len(durations) > 1 else 0
        user_stats[_username] = {'avg_time': user_avg_time, 'std_dev': user_std_dev}

    return {'global_stats': {'avg_time': global_avg_time, 'std_dev': global_std_dev},
            'user_stats': user_stats}


def calculate_most_and_least_frequent_users(log_file, n=1): # c
    user_counts = Counter()

    for log in log_file:
        username = log['username']
        if username:
            user_counts[username] += 1

    most_frequent_users = [user for user, _ in user_counts.most_common(n)]
    least_frequent_users = [user for user, _ in user_counts.most_common()[:-n - 1:-1]]

    return {'most_frequent': most_frequent_users, 'least_frequent': least_frequent_users}


def print_log_analysis(log_file):
    # a.
    random_logs_for_user = get_random_logs_for_user(log_file, n=3)
    print("\n--- a)")
    print(f"random {len(random_logs_for_user['logs'])} logs from user: {random_logs_for_user['username']}")
    for log in random_logs_for_user['logs']:
        print(log)

    # b.
    ssh_stats = calculate_ssh_connection_stats(log_file)
    print("\n--- b)")
    print(f"global average time: {ssh_stats['global_stats']['avg_time']: .2f}s")
    print(f"global standard deviation: {ssh_stats['global_stats']['std_dev']: .2f}s")
    print(f"average time for all {len(ssh_stats['user_stats'])} users: ")
    for user, stats in ssh_stats['user_stats'].items():
        print(f"username: {user}, avg_time: {stats['avg_time']: .2f}s, std_dev: {stats['std_dev']: .2f}s")

    # c.
    frequency_stats = calculate_most_and_least_frequent_users(log_file, n=5)
    print("\n--- c)")
    print(f"most common {len(frequency_stats['most_frequent'])} users: ")
    print(frequency_stats['most_frequent'])
    print(f"least common {len(frequency_stats['least_frequent'])} users: ")
    print(frequency_stats['least_frequent'])
