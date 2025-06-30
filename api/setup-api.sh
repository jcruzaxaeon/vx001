#!/bin/bash

npm init -y
npm install express mysql2 sequelize dotenv bcrypt cors jsonwebtoken basic-auth
npm install --save-dev sequelize-cli nodemon
# npm install @sendgrid/mail
# npm install --save-dev nodemon

mkdir -p config
touch config/db.js    #Initialize database connection
touch index.js .env   #Initialize express app

cat << EOF > .env
DB_NAME=dbvx1
DB_HOST=[MySQL Server IP]
DB_PORT=[MySQL Server Port]
DB_APP_USER=app
DB_APP_PASS=[Password]
EOF

echo "---------------------------------------------------------"
echo "Setup complete! A .env file has been created for you."
echo "Please open and fill in the details in your .env file:"
echo "" # Empty line for spacing
echo "DB_NAME=dbvx1"
echo "DB_HOST=[MySQL Server IP]"
echo "DB_PORT=[MySQL Server Port]"
echo "DB_APP_USER=app"
echo "DB_APP_PASS=[Password]"
echo "" # Empty line for spacing
echo "Remember to NEVER commit your actual .env file to version control!"
echo "---------------------------------------------------------"