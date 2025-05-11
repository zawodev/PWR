import sqlite3

# connect_to_db opens a connection to the sqlite file
def connect_to_db(db_path):
    return sqlite3.connect(db_path)

# get_table_names returns all table names in the database
def get_table_names(conn):
    cursor = conn.cursor()
    cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
    tables = [row[0] for row in cursor.fetchall()]
    cursor.close()
    return tables

# get_table_schema returns the schema (column names and types) for a given table
def get_table_schema(conn, table_name):
    cursor = conn.cursor()
    cursor.execute(f"PRAGMA table_info('{table_name}');")
    schema = [(col[1], col[2]) for col in cursor.fetchall()]  # (name, type)
    cursor.close()
    return schema

# get_table_row_count returns the number of rows in a given table
def get_table_row_count(conn, table_name):
    cursor = conn.cursor()
    cursor.execute(f"SELECT COUNT(*) FROM '{table_name}';")
    count = cursor.fetchone()[0]
    cursor.close()
    return count

# preview_table prints the first n rows of a table
def preview_table(conn, table_name, n=5):
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM '{table_name}' LIMIT {n};")
    rows = cursor.fetchall()
    cols = [description[0] for description in cursor.description]
    cursor.close()
    print(f"\n-- first {n} rows of {table_name} --")
    print(cols)
    for row in rows:
        print(row)

def main():
    db_path = "database.sqlite"  # change path if needed
    conn = connect_to_db(db_path)

    tables = get_table_names(conn)
    print("tables found:", tables)

    for table in tables:
        schema = get_table_schema(conn, table)
        row_count = get_table_row_count(conn, table)

        print(f"\n== table: {table} ==")
        print("schema:")
        for col_name, col_type in schema:
            print(f"  - {col_name}: {col_type}")
        print(f"total rows: {row_count}")

        # optional: preview first 5 rows
        preview_table(conn, table, n=5)

    conn.close()

if __name__ == "__main__":
    main()
