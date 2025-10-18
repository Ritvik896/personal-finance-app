#!/bin/sh

set -e

HOST=${1:-postgres}
PORT=${2:-5432}
USER=${3:-postgres}
DB=${4:-postgres}
shift 4  # Shift the first 4 args so "$@" is now the command to run

echo "Waiting for Postgres at $HOST:$PORT..."

# Wait until Postgres is ready
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$HOST" -U "$USER" -d "$DB" -c '\q' 2>/dev/null; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "Postgres is up - executing command"
exec "$@"
