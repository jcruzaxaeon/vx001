// Filename: api/config/db.js
// used-by: 
//     - api/index.js
//     - api/routes/user-routes.js
import { Sequelize } from 'sequelize';
import envConfig from './env.js';
const environment = process.env.NODE_ENV; // || 'dev';
const config = envConfig[environment];

const sequelize = new Sequelize(
  config.database,
  config.username,
  config.password,
  {
    host: config.host,
    dialect: config.dialect,
    port: config.port,
    logging: console.log, // See SQL queries in console. V2: `console.log`, V1: `true` (deprecated)

    // Connection pool settings
    pool: {
      max: 5,          // Max number of connections in pool
      min: 0,          // Min number of connections in pool
      acquire: 30000,  // Max (ms) to try connecting before throwing error
      idle: 10000      // Max (ms) a connection can be idle before being released
    }
  }
);

export default sequelize;

// Your existing MySQL connection pool
// const pool = mysql.createPool({
//   host: process.env.DB_HOST,
//   user: process.env.DB_USER,
//   password: process.env.DB_PASSWORD,
//   database: process.env.DB_NAME,
//   waitForConnections: true,
//   connectionLimit: 10,
//   queueLimit: 0
// });

// import { Sequelize } from 'sequelize';
// import dotenv from 'dotenv';

// dotenv.config({ path: '../.env' }); // Adjust path to point to your project's root .env

// const sequelize = new Sequelize(
//   process.env.DB_NAME,
//   process.env.DB_USER,
//   process.env.DB_PASSWORD,
//   {
//     host: process.env.DB_HOST,
//     dialect: process.env.DB_DIALECT,
//     logging: false, // Set to true to see SQL queries in console
//     pool: {
//       max: 5,
//       min: 0,
//       acquire: 30000,
//       idle: 10000
//     }
//   }
// );

// export default sequelize;