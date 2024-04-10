import sys
import os
import subprocess
from utils import get_backup_dir, read_backup_history

def list_backups():
    """Wyświetla listę dostępnych kopii zapasowych."""
    backup_dir = get_backup_dir()
    backups = read_backup_history(backup_dir)
    for index, backup in enumerate(backups):
        print(f"{index + 1}. Data: {backup['date']}, Katalog: {backup['source_dir']}, Plik: {backup['archive_name']}")

def restore_backup(target_dir):
    """Przywraca wybraną kopię zapasową."""
    list_backups()
    choice = int(input("Wybierz kopię do przywrócenia (numer): ")) - 1
    backups = read_backup_history(get_backup_dir())
    if choice < 0 or choice >= len(backups):
        print("Nieprawidłowy wybór")
        return

    backup_entry = backups[choice]
    archive_path = os.path.join(get_backup_dir(), backup_entry['archive_name'])

    my_dir = os.path.join(os.getcwd(), target_dir)
    if not os.path.exists(my_dir):
        os.makedirs(my_dir)
    else:
        subprocess.run(['powershell.exe', 'Remove-Item', os.path.join(my_dir, '*'), '-Recurse', '-Force'], check=True)

    # Rozpakowanie archiwum
    subprocess.run(['powershell.exe', 'Expand-Archive', '-Path', archive_path, '-DestinationPath', my_dir], check=True)


if __name__ == '__main__':
    target_dir = sys.argv[1] if len(sys.argv) > 1 else '.backups'
    restore_backup(target_dir)
