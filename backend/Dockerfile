# Use Python slim image
FROM python:3.9-slim

WORKDIR /app

# Install PostgreSQL client
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source code
COPY . .

# Make wait-for-postgres script executable
RUN chmod +x wait-for-postgres.sh

# Use wait-for-postgres to start the Flask app
CMD ["./wait-for-postgres.sh", "postgres", "5432", "postgres", "postgres", "python", "app.py"]
