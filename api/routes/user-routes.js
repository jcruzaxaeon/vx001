// api/routes/user-routes.js
import express from 'express';
import User from '../models/User.js';
import { asyncHandler } from '../middleware/error-handler.js';
import { validateUserCreate, validateUserUpdate, validateUserId } from '../middleware/validation.js';

const router = express.Router();

// GET /api/users - Get all users
router.get('/', asyncHandler(async (req, res) => {
    const users = await User.findAll({
        attributes: { exclude: ['password', 'reset_token', 'email_verification_token'] }
    });
    res.json({
        success: true,
        data: users,
        count: users.length
    });
}));

// GET /api/users/:id - Get single user
router.get('/:id', validateUserId, asyncHandler(async (req, res) => {
    const user = await User.findByPk(req.params.id, {
        attributes: { exclude: ['password', 'reset_token', 'email_verification_token'] }
    });
    if (!user) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
        // return res.status(404).json({ error: 'User not found' });
    }
    res.json({
        success: true,
        data: user
    });
    // console.error('Error fetching user:', error);
    // res.status(500).json({ error: error.message });
}));

// POST /api/users - Create new user
router.post('/', validateUserCreate, asyncHandler(async (req, res) => {
        const { email, password, username } = req.body;
        // Basic validation
        if (!email || !password) {
            const error = new Error('Email and password are required');
            error.statusCode = 400;
            throw error;
            // return res.status(400).json({ error: 'Email and password are required' });
        }
        const user = await User.create({
            email,
            password,
            username
        });
        // Return user without sensitive data
        const { password: _, reset_token: __, email_verification_token: ___, ...userResponse } = user.toJSON();
        res.status(201).json({
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
router.put('/:id', validateUserUpdate, asyncHandler(async (req, res) => {
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
router.delete('/:id', validateUserId, asyncHandler(async (req, res) => {
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

// V2
//
// ./api/routes/user-routes.js
//
// used-by: ./api/index.js
// import express from 'express';
// import User from '../models/User.js';
// import { validateUserCreateMiddleware, validateUserUpdateMiddleware } from '../middleware/validation.js';
// import { asyncHandler, AppError } from '../middleware/error-handler.js';

// const router = express.Router();

// // GET /users - Get all users
// router.get('/', asyncHandler(async (req, res) => {
//   const users = await User.findAll({
//     attributes: { exclude: ['password', 'reset_token', 'email_verification_token'] } // Don't send passwords
//   });
  
//   res.json({
//     success: true,
//     data: users,
//     count: users.length
//   });
// }));

// // GET /users/:id - Get user by ID
// router.get('/:id', asyncHandler(async (req, res) => {
//   const { id } = req.params;
  
//   const user = await User.findByPk(id, {
//     attributes: { exclude: ['password', 'reset_token', 'email_verification_token'] }
//   });
  
//   if (!user) {
//     throw new AppError('User not found', 404);
//   }
  
//   res.json({
//     success: true,
//     data: user
//   });
// }));

// // POST /users - Create new user
// router.post('/', 
//   validateUserCreateMiddleware,
//   asyncHandler(async (req, res) => {
//     const { email, password, username } = req.body;
//     console.log('Creating user:', { email, username });
    
//     // Check if user already exists
//     const existingUser = await User.findOne({ where: { email } });
//     if (existingUser) {
//       throw new AppError('User with this email already exists', 409);
//     }
    
//     const user = await User.create({
//       email,
//       password, // You'll want to hash this when you add auth
//       username
//     });
    
//     // Remove password from response
//     const userResponse = user.toJSON();
//     delete userResponse.password;
    
//     res.status(201).json({
//       success: true,
//       message: 'User created successfully',
//       data: userResponse
//     });
//   })
// );

// // PUT /users/:id - Update user
// router.put('/:id',
//   validateUserUpdateMiddleware,
//   asyncHandler(async (req, res) => {
//     const { id } = req.params;
//     const updates = req.body;
    
//     const user = await User.findByPk(id);
//     if (!user) {
//       throw new AppError('User not found', 404);
//     }
    
//     // Check email uniqueness if email is being updated
//     if (updates.email && updates.email !== user.email) {
//       const existingUser = await User.findOne({ where: { email: updates.email } });
//       if (existingUser) {
//         throw new AppError('User with this email already exists', 409);
//       }
//     }
    
//     await user.update(updates);
    
//     // Remove password from response
//     const userResponse = user.toJSON();
//     delete userResponse.password;
    
//     res.json({
//       success: true,
//       message: 'User updated successfully',
//       data: userResponse
//     });
//   })
// );

// // DELETE /users/:id - Delete user
// router.delete('/:id', asyncHandler(async (req, res) => {
//   const { id } = req.params;
  
//   const user = await User.findByPk(id);
//   if (!user) {
//     throw new AppError('User not found', 404);
//   }
  
//   await user.destroy();
  
//   res.json({
//     success: true,
//     message: 'User deleted successfully'
//   });
// }));

// V1
//
// GET /api/users - Get all users
// router.get('/', async (req, res) => {
//     try {
//         const users = await User.findAll({
//             attributes: { exclude: ['password_hash', 'reset_token', 'email_verification_token'] }
//         });
//         res.json(users);
//     } catch (error) {
//         res.status(500).json({ error: error.message });
//     }
// });

// // GET /api/users/:id - Get single user
// router.get('/:id', async (req, res) => {
//     try {
//         const user = await User.findByPk(req.params.id, {
//             attributes: { exclude: ['password_hash', 'reset_token', 'email_verification_token'] }
//         });
        
//         if (!user) {
//             return res.status(404).json({ error: 'User not found' });
//         }
        
//         res.json(user);
//     } catch (error) {
//         res.status(500).json({ error: error.message });
//     }
// });

// // POST /api/users - Create new user
// router.post('/', async (req, res) => {
//     try {
//         const { email, password_hash, username } = req.body;
        
//         const user = await User.create({
//             email,
//             password_hash,
//             username
//         });
        
//         // Return user without sensitive data
//         const { password_hash: _, reset_token: __, email_verification_token: ___, ...userResponse } = user.toJSON();
//         res.status(201).json(userResponse);
//     } catch (error) {
//         res.status(400).json({ error: error.message });
//     }
// });

// // PUT /api/users/:id - Update user
// router.put('/:id', async (req, res) => {
//     try {
//         const [updated] = await User.update(req.body, {
//             where: { user_id: req.params.id }
//         });
        
//         if (updated) {
//             const updatedUser = await User.findByPk(req.params.id, {
//                 attributes: { exclude: ['password_hash', 'reset_token', 'email_verification_token'] }
//             });
//             res.json(updatedUser);
//         } else {
//             res.status(404).json({ error: 'User not found' });
//         }
//     } catch (error) {
//         res.status(400).json({ error: error.message });
//     }
// });

// // DELETE /api/users/:id - Delete user
// router.delete('/:id', async (req, res) => {
//     try {
//         const deleted = await User.destroy({
//             where: { user_id: req.params.id }
//         });
        
//         if (deleted) {
//             res.status(204).send();
//         } else {
//             res.status(404).json({ error: 'User not found' });
//         }
//     } catch (error) {
//         res.status(500).json({ error: error.message });
//     }
// });

// export default router;