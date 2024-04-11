import os
import json
from datetime import datetime

def get_backup_dir():
    return os.environ.get('BACKUPS_DIR', os.path.join(os.path.expanduser('~'), '.backups'))

def ensure_dir_exists(path):
    os.makedirs(path, exist_ok=True)

def log_backup_entry(backup_dir, source_dir, archive_name):
    log_file_path = os.path.join(backup_dir, 'backup_history.json')
    entry = {
        'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'source_dir': source_dir,
        'archive_name': archive_name
    }

    if os.path.exists(log_file_path):
        with open(log_file_path, 'r+', encoding='utf-8') as log_file:
            log_data = json.load(log_file)
            log_data.append(entry)
            log_file.seek(0)
            json.dump(log_data, log_file, indent=4)
    else:
        with open(log_file_path, 'w', encoding='utf-8') as log_file:
            json.dump([entry], log_file, indent=4)

def read_backup_history(backup_dir):
    log_file_path = os.path.join(backup_dir, 'backup_history.json')
    if not os.path.exists(log_file_path):
        return []
    with open(log_file_path, 'r', encoding='utf-8') as log_file:
        return json.load(log_file)
