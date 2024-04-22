import random
import datetime
import statistics
import my_utils as mu
from collections import Counter

def get_random_logs_for_user(log_file, username=None, n=1):
    if username is None:
        all_users = set(log['username'] for log in log_file)
        if all_users:
            username = random.choice(list(all_users))
        else:
            return []

    user_logs = [log for log in log_file if log['username'] == username]
    return {'username': username, 'logs': random.sample(user_logs, min(n, len(user_logs)))}

"""
def calculate2_ssh_connection_stats(log_file):
    sessions = []
    user_sessions = {}

    current_year = 2013
    prev_timestamp = None
    prev_pid = None
    prev_log = None

    for log in log_file:
        # date parsing
        timestamp_str = log['timestamp']
        timestamp = datetime.datetime.strptime(timestamp_str, "%b %d %H:%M:%S").replace(year=current_year)

        if timestamp.month == 1 and prev_timestamp.month == 12:
            current_year = 2014
            timestamp.replace(year=current_year)

        # data extraction
        pid = log['pid']
        username = log['username']

        if prev_log['pid'] != log['pid']:
            if len(sessions) > 0:
                sessions[-1]['end'] = prev_timestamp
            sessions.append({'start': timestamp})

        if username:
            if username not in user_sessions:
                user_sessions[username] = []
            user_sessions[username].append(timestamp)
        prev_timestamp = timestamp
        prev_pid = pid
        prev_log = log

    # Obliczenie czasu trwania połączeń
    durations = [(session['end'] - session['start']).total_seconds() for session in sessions.values() if
                 'end' in session]

    global_stats = {'mean': None, 'stdev': None}
    if durations:
        global_stats['mean'] = statistics.mean(durations)
        if len(durations) > 1:
            global_stats['stdev'] = statistics.stdev(durations)

    user_stats = {}
    for username, timestamps in user_sessions.items():
        if len(timestamps) < 2:
            continue
        print("A")

        # Sort timestamps to ensure correct subtraction
        timestamps.sort()
        user_durations = [(timestamps[i] - timestamps[i - 1]).total_seconds() for i in range(1, len(timestamps))]
        if user_durations:
            user_mean = statistics.mean(user_durations)
            user_stdev = statistics.stdev(user_durations) if len(user_durations) > 1 else None
            user_stats[username] = {'mean': user_mean, 'stdev': user_stdev}

    return {'global_stats': global_stats, 'user_stats': user_stats}
"""

def calculate_ssh_connection_stats(log_file):
    global_duration = []
    user_durations = {}

    current_pid = None
    start_time = None
    prev_timestamp = None
    prev_username = None
    timestamp = None
    username = None

    for log in log_file:
        timestamp = datetime.datetime.strptime(log['timestamp'], "%b %d %H:%M:%S").replace(year=2013)
        pid = log['pid']
        username = log['username'] if log['username'] is not None else username

        if current_pid != pid:
            if start_time is not None and prev_timestamp is not None and prev_username is not None:
                duration = (prev_timestamp - start_time).total_seconds() #SAME AS THIS
                global_duration.append(duration)
                user_durations.setdefault(prev_username, []).append(duration)
            current_pid = pid
            start_time = timestamp
        else:
            start_time = min(start_time, timestamp)
        prev_timestamp = timestamp
        prev_username = username

    if start_time is not None:
        duration = (timestamp - start_time).total_seconds() #SAME AS THIS
        global_duration.append(duration)
        user_durations.setdefault(prev_username, []).append(duration)

    global_avg_duration = statistics.mean(global_duration)
    global_std_deviation = statistics.stdev(global_duration) if len(global_duration) > 1 else 0

    user_stats = {}
    for username, durations in user_durations.items():
        print(f"{username} : {durations}")
        user_avg_duration = statistics.mean(durations)
        user_std_deviation = statistics.stdev(durations) if len(durations) > 1 else 0
        user_stats[username] = {'avg_duration': user_avg_duration, 'stddev': user_std_deviation}

    return {'global_stats': {'avg_duration': global_avg_duration, 'stddev': global_std_deviation},
            'user_stats': user_stats}


def calculate_most_and_least_frequent_users(log_file, n=1):
    user_counts = Counter()

    for log in log_file:
        username = log['username']
        if username:
            user_counts[username] += 1

    most_frequent_users = [user for user, _ in user_counts.most_common(n)]
    least_frequent_users = [user for user, _ in user_counts.most_common()[:-n-1:-1]]

    return {'most_frequent': most_frequent_users, 'least_frequent': least_frequent_users}


def print_log_analysis(log_file):
    # a.
    random_logs_for_user = get_random_logs_for_user(log_file, n=2)
    print(f"\nrandom log from user: {random_logs_for_user['username']}")
    for log in random_logs_for_user['logs']:
        print(log)

    # b.
    ssh_stats = calculate_ssh_connection_stats(log_file)
    print("\nŚredni czas trwania połączeń SSH dla całego pliku:")
    print("Średni czas:", ssh_stats['global_stats']['avg_duration'])
    print("Odchylenie standardowe:", ssh_stats['global_stats']['stddev'])
    print("\nŚredni czas trwania połączeń SSH dla każdego użytkownika:")
    print(len(ssh_stats['user_stats']))
    for user, stats in ssh_stats['user_stats'].items():
        print(f"Użytkownik: {user}, Średni czas: {stats['avg_duration']}, Odchylenie standardowe: {stats['stddev']}")

    # c.
    frequency_stats = calculate_most_and_least_frequent_users(log_file, 5)
    print("\nNajczęściej logujący się użytkownicy:")
    print(frequency_stats['most_frequent'])
    print("\nNajrzadziej logujący się użytkownicy:")
    print(frequency_stats['least_frequent'])
