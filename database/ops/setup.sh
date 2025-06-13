#!/bin/bash

#NOTES
#   - Filename: setup-database.sh
#   - Usage: `l$./setup-database.sh {environment code}`
#   - Environment Codes: rca | test | prod
#   - rca = local development environment using PC-Name=rca with 
#       - Windows 11 running MySQL 8.0 Service
#       - WSL2 (Debian) holding database-source-code, and running backend & frontend

#LOAD ENVIRONMENT VARIABLES 
#   from `.env.{environment code}` files

#VARIABLES
ENV_CODE="${1:-rca}"   #`:-rca` => defaults to 'rca' if no argument is provided`
                       #1 => first argument passed to the script
ENV_FILE="$(dirname "$0")/../../.env.${ENV_CODE}"   #${} unecessary, but used for practice

#FUNCTIONS
load() {
    local filename="$1"   #`$1` => the first argument passed to the function

    if [ -f "$filename" ]; then
        echo "📁 Loading environment from: $filename"

        #Export variables from .env file, ignoring comments and empty lines
        #   - export $(...) - exports KEY=value pairs as local environment variables
        #   - grep -v '^#' - excludes lines starting with # (comments)
        #   - grep -v '^$' - excludes empty lines
        #   - xargs - converts multiple lines into a single line of space-separated KEY=value pairs
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

#CHECK IF ALL VARS ARE SET
#   - "${vars[@]}" - (expands / opens) array
#   - [@] - all elements as separate (words / arguments)
#   - -z - checks for empty strings (zero length)
#   - "${!var}" - returns value $var
for var in "${vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Required environment variable '$var' is not set in $ENV_FILE"
        exit 1
    fi
done

#TEST
#env | grep DB_
echo "🚀 Initializing database setup for $ENV_CODE environment..."
echo "🔧 Using database: $DB_NAME on $DB_HOST:$DB_PORT"

#CREATE DATABASE AND USER
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" << EOF

CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--CREATE USER IF NOT EXISTS '$DB_USER'@'DB_USER_HOST' IDENTIFIED BY '$DB_USER_PASS';
--GRANT SELECT, INSERT, UPDATE, DELETE ON \`$DB_NAME\`.* TO '$DB_USER'@'DB_USER_HOST';
--FLUSH PRIVILEGES;
USE \`$DB_NAME\`;

-- MIGRATION TRACKING TABLE
CREATE TABLE IF NOT EXISTS migrations (
    migration_id INT AUTO_INCREMENT PRIMARY KEY,
    migration VARCHAR(255) NOT NULL UNIQUE,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SHOW CREATED DATABASE INFO
SELECT 'Database created successfully' as status;
SHOW TABLES;
EOF

if [ $? -eq 0 ]; then
    echo "✅ Database '$DB_NAME' created successfully!"
    echo "✅ User '$DB_USER' created with full access!"
    echo "✅ Migration tracking table created!"
    echo ""
    echo "🔗 Connection details:"
    echo "   Host: $DB_HOST:$DB_PORT"
    echo "   Database: $DB_NAME"
    echo "   User: $DB_USER"
else
    echo "❌ Database initialization failed!"
    exit 1
fi

#echo "🌍 Environment: $ENV_NAME"
#echo "📁 Loading environment variables from: $ENV_FILE"