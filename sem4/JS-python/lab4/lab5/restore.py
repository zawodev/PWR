import sys
import os
import subprocess
from utils import get_backup_dir, read_backup_history

def list_backups():
    backup_dir = get_backup_dir()
    backups = read_backup_history(backup_dir)
    for index, backup in enumerate(backups):
        print(f"{index + 1}. date: {backup['date']}, folder: {backup['source_dir']}, file: {backup['archive_name']}")

def restore_backup(target_dir):
    list_backups()
    choice = int(input("wybierz kopię do przywrócenia (wpisz numer): ")) - 1
    backups = read_backup_history(get_backup_dir())
    if choice < 0 or choice >= len(backups):
        print("nieprawidłowy wybór")
        return

    backup_entry = backups[choice]
    archive_path = os.path.join(get_backup_dir(), backup_entry['archive_name'])

    cwd_target_dir = os.path.join(os.getcwd(), target_dir) # absolute path
    if not os.path.exists(cwd_target_dir):
        os.makedirs(cwd_target_dir)
    else:
        subprocess.run(['powershell.exe', 'Remove-Item', os.path.join(cwd_target_dir, '*'), '-Recurse', '-Force'], check=True)

    subprocess.run(['powershell.exe', 'Expand-Archive', '-Path', archive_path, '-DestinationPath', cwd_target_dir], check=True)


if __name__ == '__main__':
    _target_dir = sys.argv[1] if len(sys.argv) > 1 else '.backups'
    restore_backup(_target_dir)
