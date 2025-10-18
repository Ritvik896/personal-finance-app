#!/bin/sh
set -e

# Load .env
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
fi

# Use environment variables
HOST=${POSTGRES_HOST:-localhost}
PORT=${POSTGRES_PORT:-5432}
USER=${POSTGRES_USER:-postgres}
DB=${POSTGRES_DB:-postgres}
PASS=${POSTGRES_PASSWORD:-postgres}

echo "Waiting for Postgres at $HOST:$PORT..."

until PGPASSWORD=$PASS psql -h "$HOST" -U "$USER" -d "$DB" -c '\q' 2>/dev/null; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "Postgres is up - executing command"
exec "$@"
