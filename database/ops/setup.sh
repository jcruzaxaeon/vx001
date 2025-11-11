#!/bin/bash

# ./database/ops/setup.sh
# Initializes project db with only a migration-table

#Requires `.env.setup` file to be present in the same directory

#SET STRICT MODE
#   -e (Exit on Error): Exit immediately if a command exits with a non-zero status.
#   -u (Undefined Variables): Treat unset variables as an error and exit immediately.
#   -o pipefail: Prevents errors in a pipeline from being masked.
#      - If any command in a pipeline fails, the entire pipeline fails.
#      - Without this, only the last command's exit status matters.
set -euo pipefail

#LOAD ENVIRONMENT VARIABLES
if [[ ! -f ".env.setup" ]]; then
    echo "⚠️  Environment file '.env.setup' not found!"
    exit 1
fi
source .env.setup

echo " Creating database: $DB_NAME"

mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ADMIN_USER" -p"$DB_ADMIN_PASS" << EOF

--DATABASE
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--DEVELOPMENT USER
--   GRANT PRIVILEGES for
--      - Data operations
--      - Schema modifications
--      - Stored procedures/functions
--      - Development helpers
CREATE USER '$DB_DEV_USER'@'$DB_DEV_HOST' IDENTIFIED BY '$DB_DEV_PASS'; 
GRANT SELECT, INSERT, UPDATE, DELETE ON \`$DB_NAME\`.* TO '$DB_DEV_USER'@'$DB_DEV_HOST';
GRANT CREATE, DROP, ALTER, INDEX ON \`$DB_NAME\`.* TO '$DB_DEV_USER'@'$DB_DEV_HOST';
GRANT CREATE ROUTINE, ALTER ROUTINE, EXECUTE ON \`$DB_NAME\`.* TO '$DB_DEV_USER'@'$DB_DEV_HOST';
GRANT CREATE TEMPORARY TABLES ON \`$DB_NAME\`.* TO '$DB_DEV_USER'@'$DB_DEV_HOST';
GRANT PROCESS ON *.* TO '$DB_DEV_USER'@'$DB_DEV_HOST';
GRANT EVENT, LOCK TABLES ON \`$DB_NAME\`.* TO '$DB_DEV_USER'@'$DB_DEV_HOST';

--APPLICATION USER
--   GRANT PRIVILEGES for
--      - CRUD operations only
CREATE USER '$DB_APP_USER'@'$DB_APP_HOST' IDENTIFIED BY '$DB_APP_PASS';
GRANT SELECT, INSERT, UPDATE, DELETE ON \`$DB_NAME\`.* TO '$DB_APP_USER'@'$DB_APP_HOST';

FLUSH PRIVILEGES;

USE \`$DB_NAME\`;

--MIGRATION HISTORY TABLE
CREATE TABLE IF NOT EXISTS migrations (
    migration_id INT AUTO_INCREMENT PRIMARY KEY,
    migration VARCHAR(255) NOT NULL UNIQUE,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SHOW DATABASES;
SELECT User, Host FROM mysql.user;
SHOW TABLES;

EOF

echo "✅ Database '$DB_NAME' and user-roles created successfully!"