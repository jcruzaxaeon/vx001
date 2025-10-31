// api/routes/user-routes.js
import express from 'express';
import User from '../models/User.js';
import { asyncHandler } from '../middleware/error-handler.js';
// import { validateUserCreate, validateUserUpdate, validateUserId } from '../middleware/validation_reference.js';
import { 
    validateEmail, 
    validatePassword, 
    validateIdNumber } from '../middleware/validation.js';
import { 
   requireAuth,
   requireOwnership } from '../middleware/authentication.js';

const router = express.Router();

// GET /api/users - Get all users
router.get('/', 
   requireAuth,
   asyncHandler(async (req, res) => {
      const users = await User.findAll({
         attributes: { exclude: ['password', 'reset_token', 'email_verification_token'] }
      });
      res.json({
         success: true,
         data: users,
         count: users.length
      });
   })
);

// GET /api/users/:id - Get single user
// router.get('/:id', validateUserId, asyncHandler(async (req, res) => {
router.get('/:id', validateIdNumber, asyncHandler(async (req, res) => {
    const user = await User.findByPk(req.params.id, {
        attributes: { exclude: ['password', 'reset_token', 'email_verification_token'] }
    });
    if (!user) {
        const issues = [];
        issues.push({
            name: 'UserNotFound',
            message: `User with ID ${req.params.id} not found`,
            data: {
                userId: req.params.id
            }
        });

        const error = new Error('User not found');
        error.type = '/user-not-found';
        error.title = 'User Not Found';
        error.status = 404;
        error.detail = `User with ID ${req.params.id} not found`;
        error.instance = req.originalUrl;
        error.issues = issues;
        throw error;
    }
    res.json({
        success: true,
        data: user
    });
}));

// CREATE USER --- POST /api/users
router.post('/', 
    validateEmail,
    validatePassword,
    //validateUserCreate, 
    asyncHandler(async (req, res) => {
        const { email, password, username } = req.body;

        const user = await User.create({
            email,
            password,
            username
        });
        // Return user without sensitive data
        const { password: _, reset_token: __, email_verification_token: ___, ...userResponse } = user.toJSON();
        res.status(201).json({
            // !mark
            success: true,
            data: userResponse,
            message: 'User created successfully'
        });


        // console.error('Error creating user:', error);
        // // Handle unique constraint errors
        // if (error.name === 'SequelizeUniqueConstraintError') {
        //     return res.status(409).json({ error: 'User with this email already exists' });
        // }
        // res.status(400).json({ error: error.message });
}));

// PUT /api/users/:id - Update user
router.put('/:id',
   //  validateEmail,
   //  validatePassword,
   validateIdNumber,
   requireAuth,
   requireOwnership,
    //validateUserUpdate, 
    asyncHandler(async (req, res) => {
        const [updated] = await User.update(req.body, {
            where: { user_id: req.params.id }
        });
        if(!updated) {
            const error = new Error('User not found');
            error.statusCode = 404;
            throw error;
        }
        const updatedUser = await User.findByPk(req.params.id, {
            attributes: { exclude: ['password', 'reset_token', 'email_verification_token'] }
        });
        res.json({
            success: true,
            data: updatedUser,
            message: 'User updated successfully'
        });
        // } else {
        //     res.status(404).json({ error: 'User not found' });
        // }

        // console.error('Error updating user:', error); 
        // // Handle unique constraint errors
        // if (error.name === 'SequelizeUniqueConstraintError') {
        //     return res.status(409).json({ error: 'Email already exists' });
        // }
        // res.status(400).json({ error: error.message });
}));

// DELETE /api/users/:id - Delete user
router.delete('/:id', 
   validateIdNumber,
   requireAuth,
   requireOwnership,
   /*validateUserId,*/ 
   asyncHandler(async (req, res) => {
      const deleted = await User.destroy({
         where: { user_id: req.params.id }
      });
      if(!deleted) {
         const error = new Error('User not found');
         error.statusCode = 404;
         throw error;
      }       
      res.json({
         success: true,
         message: 'User deleted successfully'
      });

      // if (deleted) {
      //     res.status(204).send();
      // } else {
      //     res.status(404).json({ error: 'User not found' });
      // }

      // console.error('Error deleting user:', error);
      // res.status(500).json({ error: error.message });

}));

export default router;