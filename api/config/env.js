// ./config/env.js

import dotenv from 'dotenv';

if (process.env.NODE_ENV !== 'production') { dotenv.config(); }

const config = {
    dev: {
        username: process.env.DB_APP_USER,
        password: process.env.DB_APP_PASS,
        database: process.env.DB_NAME,
        host: process.env.DB_HOST,
        dialect: process.env.DB_DIALECT,
        port: process.env.DB_PORT,
    },
    // production: {
    //     username: process.env.MYSQLUSER,
    //     password: process.env.MYSQLPASSWORD,
    //     database: process.env.MYSQLDATABASE,
    //     host: process.env.MYSQLHOST,
    //     dialect: 'mysql',
    //     port: process.env.MYSQLPORT,
    // },
};

export default config;