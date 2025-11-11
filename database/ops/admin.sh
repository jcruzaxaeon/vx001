#!/bin/bash

# ./database/ops/admin.sh
# - Creates an `admin` user to manage project specific users
# - Requires `.env.setup` file to be present in the same directory

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

sudo mysql << EOF

CREATE USER '$DB_ADMIN_USER'@'$DB_ADMIN_HOST' IDENTIFIED BY '$DB_ADMIN_PASS';
GRANT ALL PRIVILEGES ON *.* TO '$DB_ADMIN_USER'@'$DB_ADMIN_HOST' WITH GRANT OPTION;
FLUSH PRIVILEGES;

SHOW DATABASES;
SELECT User, Host FROM mysql.user;
EOF

echo "✅ User '$DB_ADMIN_USER' created successfully!"