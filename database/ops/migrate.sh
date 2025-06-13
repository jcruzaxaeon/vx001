#!/bin/bash

#VARIABLES
ENV_CODE="${1:-rca}"
ENV_FILE="$(dirname "$0")/../../.env.${ENV_CODE}"
SCRIPT_DIR="$(dirname "$0")"
MIGRATIONS_DIR="$SCRIPT_DIR/../migrations"

#FUNCTIONS
load() {
    local filename="$1"

    if [ -f "$filename" ]; then
        echo "📁 Loading environment from: $filename"
        export $(grep -v '^#' "$filename" | grep -v '^$' | xargs)
    else
        echo "⚠️  Environment file '$filename' not found!"
        echo "Please create it with the required database variables."
        exit 1
    fi
}
load "$ENV_FILE"

#VALIDATION
vars=("DB_HOST" "DB_PORT" "DB_ROOT_USER" "DB_ROOT_PASS" "DB_NAME" "DB_USER" "DB_USER_PASS" "DB_USER_HOST")
for var in "${vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Required environment variable '$var' is not set in $ENV_FILE"
        exit 1
    fi
done

#FUNCTIONS
migrate() {
    local filename="$1"
    if [ ! -f "$filename" ]; then
        echo "⚠️ Migration file '$filename' not found!"
        exit 1
    fi
    echo "📄 Applying migration: $filename"

    echo "🔄 Starting database migration for $ENV_CODE environment..."

    # Run the migration script
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" "$DB_NAME" < "$1"

    if [ $? -eq 0 ]; then
        echo "✅ Migration completed successfully!"
    else
        echo "❌ Migration failed!"
        exit 1
    fi
}

# Run all up migrations in order
echo "🚀 Running migrations..."
for file in "$MIGRATIONS_DIR"/*.up.sql; do
    if [ -f "$file" ]; then
        echo "🔍 Found migration file: $file"
        migrate "$file"
    fi
done

echo "✅ All migrations completed!"