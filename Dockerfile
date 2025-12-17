# Используем официальный slim-образ
FROM python:3.11-slim

# Устанавливаем системные зависимости, curl И GOSU
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Создать рабочую директорию
WORKDIR /app

# Копируем файл зависимостей
COPY requirements.txt .

# Устанавливаем зависимости Python
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY . .

# Создание non-root пользователя и группы
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Передаем права владения non-root пользователю для рабочей папки
# Мы оставим права ROOT на сам Python, но отдадим права на код приложения
RUN chown -R appuser:appgroup /app
 
# Переключимся на non-root пользователя только для документации, 
# но для запуска CMD мы используем gosu
# USER appuser 

# Проверка здоровья контейнера. HEALTHCHECK должен работать под ROOT или GOSU.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD gosu appuser curl -f http://localhost:8000/health || exit 1 

# Порт, который будет слушать приложение
EXPOSE 8000

# ГАРАНТИРОВАННАЯ КОМАНДА ЗАПУСКА: 
# Запускаем gosu от ROOT, чтобы безопасно выполнить команду uvicorn от appuser
# Мы используем python -m, так как это самый надежный способ найти uvicorn
CMD ["gosu", "appuser", "python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]