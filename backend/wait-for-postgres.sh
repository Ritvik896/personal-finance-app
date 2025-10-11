# Use official Python image
FROM python:3.9-slim

WORKDIR /app

# Install psql client and other dependencies
RUN apt-get update && apt-get install -y postgresql-client gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source code
COPY . .

# Make wait script executable
RUN chmod +x wait-for-postgres.sh

ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_ENV=development

EXPOSE 5000

CMD ["./wait-for-postgres.sh", "postgres:5432", "--", "flask", "run"]
