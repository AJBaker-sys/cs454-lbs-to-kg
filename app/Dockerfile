FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Run with Gunicorn (better than flask dev server)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
