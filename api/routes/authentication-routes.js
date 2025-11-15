// api/routes/auth.js
import express from 'express';
import bcrypt from 'bcrypt';
import User from '../models/User.js';
import { asyncHandler } from '../middleware/error-handler.js';
import { validateEmail, validatePassword } from '../middleware/validation.js';
import { 
   requireAuth,
   requireOwnership } from '../middleware/authentication.js';

const router = express.Router();

// POST /api/auth/register - Create new user
router.post('/register',
    validateEmail,
    validatePassword,
    asyncHandler(async (req, res) => {
        const { email, password, username } = req.body;

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await User.create({
            email,
            password: hashedPassword,
            username
        });

        // Auto-login after registration
        req.session.userId = user.user_id;
        req.session.email = user.email;

        // Return user without sensitive data
        const { password: _, reset_token: __, email_verification_token: ___, ...userResponse } = user.toJSON();

        res.status(201).json({
            success: true,
            data: userResponse,
            message: 'User registered successfully'
        });
    })
);

// POST /api/auth/login - Login user
router.post('/login',
    validateEmail,
    validatePassword,
    asyncHandler(async (req, res) => {
        const { email, password } = req.body;

        // Find user
        const user = await User.findOne({
            where: { email }
        });

        if (!user) {
            const error = new Error('Invalid credentials');
            error.type = '/invalid-credentials';
            error.title = 'Invalid Credentials';
            error.status = 401;
            error.detail = 'Invalid email or password';
            error.instance = req.originalUrl;
            throw error;
        }

        // Verify password
        const validPassword = await bcrypt.compare(password, user.password);

        if (!validPassword) {
            const error = new Error('Invalid credentials');
            error.type = '/invalid-credentials';
            error.title = 'Invalid Credentials';
            error.status = 401;
            error.detail = 'Invalid email or password';
            error.instance = req.originalUrl;
            throw error;
        }

        // Create session
        req.session.userId = user.user_id;
        req.session.email = user.email;

        console.log('Session after login:', req.session); //DEBUG
        console.log('Session ID:', req.sessionID); //DEBUG

        // Return user without sensitive data
        const { password: _, reset_token: __, email_verification_token: ___, ...userResponse } = user.toJSON();

        res.json({
            success: true,
            data: userResponse,
            message: 'Login successful'
        });
    })
);

// POST /api/auth/logout - Logout user
router.post('/logout',
    requireAuth,
    // requireOwnership,
    asyncHandler(async (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            const error = new Error('Logout failed');
            error.status = 500;
            throw error;
        }

        res.clearCookie('connect.sid'); // Adjust cookie name if different
        res.json({
            success: true,
            message: 'Logout successful'
        });
    });
}));

// GET /api/auth/me - Get current user (check if logged in)
router.get('/me', asyncHandler(async (req, res) => {
    console.log('Session in /me:', req.session); // DEBUG
    console.log('Session ID in /me:', req.sessionID); // DEBUG
    console.log('User ID from session:', req.session.userId); // DEBUG

    if (!req.session.userId) {
        const error = new Error('Not authenticated');
        error.type = '/not-authenticated';
        error.title = 'Not Authenticated';
        error.status = 401;
        error.detail = 'User is not logged in';
        error.instance = req.originalUrl;
        throw error;
    }

    const user = await User.findByPk(req.session.userId, {
        attributes: { exclude: ['password', 'reset_token', 'email_verification_token'] }
    });

    if (!user) {
        const error = new Error('User not found');
        error.type = '/user-not-found';
        error.title = 'User Not Found';
        error.status = 404;
        error.detail = `User with ID ${req.session.userId} not found`;
        error.instance = req.originalUrl;
        throw error;
    }

    res.json({
        success: true,
        data: user
    });
}));

export default router;