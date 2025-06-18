#!/bin/bash
set -euo pipefail

#Requires `.env.setup` file to be present in the same directory

#LOAD ENVIRONMENT VARIABLES
if [[ ! -f ".env.setup" ]]; then
    echo "⚠️  Environment file '.env.setup' not found!"
    exit 1
fi
source .env.setup

echo "🗑️  WARNING: This will destroy database '$DB_NAME' and all user roles!"
echo "Are you sure you want to continue? (y/n)"
read -r confirmation

if [[ "$confirmation" != "y" ]]; then
    echo "❌ Destruction cancelled."
    exit 0
fi

echo "💥 Destroying database: $DB_NAME"

mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ADMIN_USER" -p"$DB_ADMIN_PASS" << EOF

--DROP DATABASE USERS FIRST (can't drop if they have active connections)
DROP USER IF EXISTS '$DB_DEV_USER'@'$DB_DEV_HOST';
DROP USER IF EXISTS '$DB_APP_USER'@'$DB_APP_HOST';

--DROP DATABASE (this removes all tables automatically)
DROP DATABASE IF EXISTS \`$DB_NAME\`;

FLUSH PRIVILEGES;

--DEBUG: Show remaining databases
SHOW DATABASES;

--DEBUG: Confirm users are gone
SELECT User, Host FROM mysql.user;
--WHERE User IN ('$DB_DEV_USER', '$DB_APP_USER');

EOF

echo "✅ Database '$DB_NAME' and user-roles destroyed successfully!"
echo "   You can now run setup.sh to recreate everything."