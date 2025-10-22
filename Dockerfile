# Use Python slim image
FROM python:3.9-slim

WORKDIR /app

# Install PostgreSQL client (for health checks)
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend source code
COPY backend/ ./backend/

# Make wait-for-postgres script executable
RUN chmod +x backend/wait-for-postgres.sh

# Start the Flask app only after DB is ready
CMD ["./backend/wait-for-postgres.sh", "python", "backend/app.py"]
