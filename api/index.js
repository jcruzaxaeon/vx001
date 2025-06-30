// ./index.js

import sequelize from "./config/db.js";

// APPLICATION
//
import express from 'express';
import cors from 'cors';
const app = express();
const port = process.env.PORT || 3000;
// const enableGlobalErrorLogging = process.env.ENABLE_GLOBAL_ERROR_LOGGING;

app.use(cors());
app.use(express.json());

// Test DB Connection
sequelize.authenticate()
    .then(() => {
        console.log('Connection made.')
    })
    .catch(err => {
        console.error('Unable to connect\n\n', err);
    });

// Basic route for testing
app.get('/', (req, res) => {
    res.send('API is running...');
});

app.listen(port, () => {
    console.log(`App running on http://localhost:${port}`);
});



// import express from 'express';
// import cors from 'cors';
// import dotenv from 'dotenv';
// import sequelize from './config/db.js';

// // Import your route files
// // import userRoutes from './routes/user-routes.js';
// // import reviewRoutes from './routes/review-routes.js';
// // import nodeRoutes from './routes/node-routes.js'; // Adjust if Node.js was a typo

// dotenv.config({ path: '../.env' }); // Adjust path to point to your project's root .env

// const app = express();
// const PORT = process.env.PORT || 5000;

// // Middleware
// app.use(express.json()); // For parsing application/json
// app.use(cors()); // Enable CORS for all routes

// // Test database connection
// sequelize.authenticate()
//   .then(() => {
//     console.log('Database connection has been established successfully.');
//   })
//   .catch(err => {
//     console.error('Unable to connect to the database:', err);
//   });

// // Basic route for testing
// app.get('/', (req, res) => {
//   res.send('API is running...');
// });

// // Use your routes (uncomment and add as you create them)
// // app.use('/api/users', userRoutes);
// // app.use('/api/reviews', reviewRoutes);
// // app.use('/api/nodes', nodeRoutes); // Adjust if Node.js was a typo

// // Start the server
// app.listen(PORT, () => {
//   console.log(`Server running on port ${PORT}`);
// });