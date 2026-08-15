FROM python:3.11-slim-bookworm

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

#up gunicorn worker processes
CMD ["gunicorn", "--workers=4", "--bind=0.0.0.0:5000", "app:app"]
