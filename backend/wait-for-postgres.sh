#!/bin/sh

# Wait-for-Postgres script
# Usage: ./wait-for-postgres.sh <host> <port> <user> <db>

set -e

HOST=${1:-postgres}
PORT=${2:-5432}
USER=${3:-postgres}
DB=${4:-postgres}

echo "Waiting for postgres at $HOST:$PORT..."

# Install PostgreSQL client if not present
if ! command -v psql > /dev/null; then
    echo "psql not found. Installing postgresql-client..."
    apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*
fi

# Wait until Postgres is ready
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$HOST" -U "$USER" -d "$DB" -c '\q' 2>/dev/null; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "Postgres is up - executing command"
exec "$@"
