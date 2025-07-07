// Filename: api/index.js
import './config/setup-env.js';
import envConfig from './config/env.js';
const environment = process.env.NODE_ENV; // || 'development';
const config = envConfig[environment];

import sequelize from "./config/db.js";
import express from 'express';
import cors from 'cors';

// CM016
// import { globalErrorHandler, notFoundHandler } from './middleware/zx_error-handler_1.js';

// Import routes
import userRoutes from './routes/user-routes.js';
import { errorHandler } from './middleware/error-handler.js';

const app = express();
const apiPort = config.apiPort; // CM016
console.log(apiPort)

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));   //[?]

// Test DB Connection (startup check)
sequelize.authenticate()
    .then(() => {
        console.log('Database connected on startup');
    })
    .catch(err => {
        console.error('Startup DB connection failed:', err);
    });

// Health check endpoint
app.get('/api/health', async (req, res) => {
    console.log('Health check endpoint hit');
    try {
        await sequelize.authenticate();
        res.json({ 
            status: 'healthy', 
            database: 'connected',
            timestamp: new Date().toISOString() 
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'unhealthy', 
            database: 'disconnected',
            error: error.message 
        });
    }
});

// Basic route for testing
app.get('/', (req, res) => {
    res.send('API is running...');
});

// API Routes
app.use('/api/users', userRoutes);

// Handle 404 routes
// app.use(notFoundHandler);
app.use((req, res, next) => {
    const error = new Error(`Route ${req.originalUrl} not found`);
    error.statusCode = 404;
    next(error);
});

// Global error handler (must be last)
app.use(errorHandler);

// Start server
app.listen(apiPort, async () => {
    try {
        await sequelize.authenticate();
        console.log(`✅ Database connected successfully`);
        console.log(`🚀 Server running on port ${apiPort}`);
        console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
    } catch (error) {
        console.error('Database connection failed:', error);
        process.exit(1); // Exit if DB connection fails
    }
});

export default app;