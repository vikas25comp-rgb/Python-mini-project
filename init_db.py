"""
Database Initialization Script
Runs database/schema.sql and database/sample_data.sql against PostgreSQL.
Usage:
    python init_db.py
"""

import os
from database import get_db_connection

def run_sql_file(conn, filepath):
    print(f"Executing: {filepath}...")
    with open(filepath, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    cursor = conn.cursor()
    try:
        cursor.execute(sql_content)
        conn.commit()
        print(f"Successfully executed: {filepath}")
    except Exception as e:
        conn.rollback()
        print(f"Error executing {filepath}: {e}")
        raise e
    finally:
        cursor.close()

def main():
    print("Connecting to PostgreSQL using credentials from .env...")
    try:
        conn = get_db_connection()
        print("Connected successfully!")
    except Exception as e:
        print(f"\nFailed to connect to database: {e}")
        print("Please ensure PostgreSQL is running and .env contains valid credentials.")
        return

    base_dir = os.path.dirname(os.path.abspath(__file__))
    schema_path = os.path.join(base_dir, 'database', 'schema.sql')
    sample_data_path = os.path.join(base_dir, 'database', 'sample_data.sql')

    try:
        run_sql_file(conn, schema_path)
        run_sql_file(conn, sample_data_path)
        print("\nDatabase initialization complete! All tables and sample data have been loaded.")
    except Exception as e:
        print(f"\nInitialization failed: {e}")
    finally:
        conn.close()

if __name__ == '__main__':
    main()
