// Filename: config/env.js
// Used-by: 
//    - config/db.js
//    - api/index.js


// Globals set in .env file
//NODE_ENV=[development, staging, production]

const config = {
    development: {
        username: process.env.DB_APP_USER,
        password: process.env.DB_APP_PASS,
        database: process.env.DB_NAME,
        host: process.env.DB_HOST,
        dialect: process.env.DB_DIALECT,
        port: process.env.DB_PORT,
        apiPort: process.env.API_PORT || 3000,
    },
    // production: {
    //     username: process.env.MYSQLUSER,
    //     password: process.env.MYSQLPASSWORD,
    //     database: process.env.MYSQLDATABASE,
    //     host: process.env.MYSQLHOST,
    //     dialect: 'mysql',
    //     port: process.env.MYSQLPORT || 3306,
    //     apiPort: process.env.API_PORT || 80,
    // },
};

export default config;