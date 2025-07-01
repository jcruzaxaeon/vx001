// ./api/index.js
import sequelize from "./config/db.js";
import express from 'express';
import cors from 'cors';

// Import routes
import userRoutes from './routes/user-routes.js';

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

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

// Start server
app.listen(port, () => {
    console.log(`App running on http://localhost:${port}`);
});