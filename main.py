import os
from fastapi import FastAPI
import psycopg2

app = FastAPI()

# Переменные окружения для подключения к БД (должны совпадать с docker-compose.yml)
DB_HOST = os.environ.get("POSTGRES_HOST", "db")
DB_NAME = os.environ.get("POSTGRES_DB", "mydatabase")
DB_USER = os.environ.get("POSTGRES_USER", "myuser")
DB_PASS = os.environ.get("POSTGRES_PASSWORD", "mypassword")

@app.get("/health")
def health_check():
    """Проверяет работоспособность сервиса и доступность БД."""
    db_status = "OK"
    try:
        # Попытка подключиться к PostgreSQL
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            connect_timeout=3
        )
        conn.close()
    except Exception as e:
        # Если подключиться не удалось, статус будет Error
        print(f"Ошибка подключения к БД: {e}")
        db_status = f"Error: {type(e).__name__}"
    
    return {"status": "OK", "db_status": db_status}

@app.get("/")
def read_root():
    return {"message": "Welcome to the Lab Docker App!"}