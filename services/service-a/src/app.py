import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

def check_db_connection():
    """Checks the connection to the PostgreSQL database."""
    # Check if the database is explicitly disabled for this service via an env var.
    # This is useful if you want to run the service without a DB connection.
    if os.getenv('DATABASE_ENABLED', 'true').lower() == 'false':
        return {"status": "disabled"}

    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=os.getenv("DB_PORT", 5432),
            user=os.getenv("DB_USER", "user"),
            password=os.getenv("DB_PASSWORD", "password"),
            dbname=os.getenv("DB_NAME", "postgres"),
            connect_timeout=3
        )
        conn.close()
        return {"status": "connected"}
    except Exception as e:
        return {
            "status": "error",
            "error_message": str(e)
        }

@app.route('/')
def home():
    db_status = check_db_connection()
    return jsonify({
        "service_name": "Service A",
        "version": "1.0.0",
        "database": db_status
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)