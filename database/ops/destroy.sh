#!/bin/bash

#NOTES
#   - Filename: database-teardown.sh
#   - Usage: `l$ ./database-teardown.sh {environment code}`
#   - Environment Codes: rca | test | prod
#   - rca = local development environment using PC-Name=rca with 
#       - Windows 11 running MySQL 8.0 Database Service
#       - WSL2 (Debian) holding database-source-code, and running backend & frontend
#   - DANGER: This script DELETES databases and users!

#VARIABLES
ENV_CODE="${1:-rca}"
ENV_FILE="$(dirname "$0")/../../.env.${ENV_CODE}"

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

#SAFETY CONFIRMATION
echo "⚠️  DANGER: This will DELETE the following:"
echo "   🗃️  Database: $DB_NAME"
echo "   👤 User: $DB_USER"
echo "   🌍 Environment: $ENV_CODE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Operation cancelled"
    exit 0
fi

echo "🧹 Starting database teardown for $ENV_CODE environment..."

#DELETE DATABASE
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" << EOF

-- Drop the database (this deletes everything inside it)
DROP DATABASE IF EXISTS \`$DB_NAME\`;

-- [ ] Drop the user
--DROP USER IF EXISTS '$DB_USER'@'$DB_USER_HOST';
-- [ ] Drop global privileges for the user

-- Show remaining databases
SHOW DATABASES;

EOF

if [ $? -eq 0 ]; then
    echo "✅ Database '$DB_NAME' deleted successfully!"
    echo "✅ User '$DB_USER' removed successfully!"
    echo "🧹 Teardown complete!"
else
    echo "❌ Database teardown failed!"
    exit 1
fi