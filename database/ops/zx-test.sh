#!/bin/bash
source .env.init

echo "Testing user creation with these values:"
echo "DEV_USER: '$DB_DEV_USER'"
echo "DEV_HOST: '$DB_DEV_HOST'"

mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ADMIN_USER" -p"$DB_ADMIN_PASS" -e "
DROP USER IF EXISTS '$DB_DEV_USER'@'$DB_DEV_HOST';
CREATE USER '$DB_DEV_USER'@'$DB_DEV_HOST' IDENTIFIED BY '$DB_DEV_PASS';
SELECT User, Host FROM mysql.user WHERE User = '$DB_DEV_USER';
"