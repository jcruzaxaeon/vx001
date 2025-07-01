// ./api/routes/user-routes.js
//
// used-by: ./api/index.js
import express from 'express';
import User from '../models/User.js';

const router = express.Router();

// GET /api/users - Get all users
router.get('/', async (req, res) => {
    try {
        const users = await User.findAll({
            attributes: { exclude: ['password_hash', 'reset_token', 'email_verification_token'] }
        });
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET /api/users/:id - Get single user
router.get('/:id', async (req, res) => {
    try {
        const user = await User.findByPk(req.params.id, {
            attributes: { exclude: ['password_hash', 'reset_token', 'email_verification_token'] }
        });
        
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        res.json(user);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST /api/users - Create new user
router.post('/', async (req, res) => {
    try {
        const { email, password_hash, username } = req.body;
        
        const user = await User.create({
            email,
            password_hash,
            username
        });
        
        // Return user without sensitive data
        const { password_hash: _, reset_token: __, email_verification_token: ___, ...userResponse } = user.toJSON();
        res.status(201).json(userResponse);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// PUT /api/users/:id - Update user
router.put('/:id', async (req, res) => {
    try {
        const [updated] = await User.update(req.body, {
            where: { user_id: req.params.id }
        });
        
        if (updated) {
            const updatedUser = await User.findByPk(req.params.id, {
                attributes: { exclude: ['password_hash', 'reset_token', 'email_verification_token'] }
            });
            res.json(updatedUser);
        } else {
            res.status(404).json({ error: 'User not found' });
        }
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// DELETE /api/users/:id - Delete user
router.delete('/:id', async (req, res) => {
    try {
        const deleted = await User.destroy({
            where: { user_id: req.params.id }
        });
        
        if (deleted) {
            res.status(204).send();
        } else {
            res.status(404).json({ error: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;