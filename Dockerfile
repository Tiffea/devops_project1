#slim - упрощенная версия
FROM python:3.11-slim

#теперь все команды от лица этой дирректории
WORKDIR /app

COPY requirements.txt .

#устанавливаем все необходимые зависимости
RUN pip install -r requirements.txt

#копирует в себя все что есть в папке
COPY . .

#развертываем на порт 5000
EXPOSE 5000

#запусти процесс python и app.py
CMD ["python", "app.py"]

