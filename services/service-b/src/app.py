import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

def check_db_connection():
    """Checks the connection to the PostgreSQL database."""
    try:
        # Get credentials from environment variables. Use a default if not set.
        db_host = os.getenv("DB_HOST", "localhost")
        db_port = os.getenv("DB_PORT", 5432)
        db_user = os.getenv("DB_USER", "user")
        db_name = os.getenv("DB_NAME", "postgres")
        
        # This is the most critical part. Get the password.
        db_password = os.getenv("PGPASSWORD")
        if not db_password:
            db_password = "password" # Explicitly set a default if it's None or empty

        conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            user=db_user,
            password=db_password,
            dbname=db_name,
            connect_timeout=3
        )
        conn.close()
        return {"status": "connected"}
    except Exception as e:
        return {
            "status": "error",
            "host": db_host,
            "port": db_port,
            "user": db_user,
            "name": db_name,
            "password": db_password,
            "error_message": str(e)
        }

@app.route('/')
def home():
    db_status = check_db_connection()
    return jsonify({
        "service_name": "Service B",
        "version": "1.0.0",
        "database": db_status
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)