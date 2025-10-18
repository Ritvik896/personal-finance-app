# Use Python slim image
FROM python:3.9-slim

WORKDIR /app

# Install PostgreSQL client
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Copy backend and install dependencies
COPY backend/requirements.txt backend/
RUN pip install --no-cache-dir -r backend/requirements.txt

# Copy entire backend
COPY backend/ backend/

# Make wait-for-postgres.sh executable
RUN chmod +x backend/wait-for-postgres.sh

# Start app using wait-for-postgres
CMD ["./backend/wait-for-postgres.sh", "python", "./backend/app.py"]
