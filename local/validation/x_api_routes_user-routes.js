const express = require('express');
const { User } = require('../models');
const { validateUserCreateMiddleware, validateUserUpdateMiddleware } = require('../middleware/validation');
const { asyncHandler, AppError } = require('../middleware/error-handler');

const router = express.Router();

// GET /users - Get all users
router.get('/', asyncHandler(async (req, res) => {
  const users = await User.findAll({
    attributes: { exclude: ['password'] } // Don't send passwords
  });
  
  res.json({
    success: true,
    data: users,
    count: users.length
  });
}));

// GET /users/:id - Get user by ID
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  const user = await User.findByPk(id, {
    attributes: { exclude: ['password'] }
  });
  
  if (!user) {
    throw new AppError('User not found', 404);
  }
  
  res.json({
    success: true,
    data: user
  });
}));

// POST /users - Create new user
router.post('/', 
  validateUserCreateMiddleware,
  asyncHandler(async (req, res) => {
    const { email, password, firstName, lastName } = req.body;
    
    // Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      throw new AppError('User with this email already exists', 409);
    }
    
    const user = await User.create({
      email,
      password, // You'll want to hash this when you add auth
      firstName,
      lastName
    });
    
    // Remove password from response
    const userResponse = user.toJSON();
    delete userResponse.password;
    
    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: userResponse
    });
  })
);

// PUT /users/:id - Update user
router.put('/:id',
  validateUserUpdateMiddleware,
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const updates = req.body;
    
    const user = await User.findByPk(id);
    if (!user) {
      throw new AppError('User not found', 404);
    }
    
    // Check email uniqueness if email is being updated
    if (updates.email && updates.email !== user.email) {
      const existingUser = await User.findOne({ where: { email: updates.email } });
      if (existingUser) {
        throw new AppError('User with this email already exists', 409);
      }
    }
    
    await user.update(updates);
    
    // Remove password from response
    const userResponse = user.toJSON();
    delete userResponse.password;
    
    res.json({
      success: true,
      message: 'User updated successfully',
      data: userResponse
    });
  })
);

// DELETE /users/:id - Delete user
router.delete('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  const user = await User.findByPk(id);
  if (!user) {
    throw new AppError('User not found', 404);
  }
  
  await user.destroy();
  
  res.json({
    success: true,
    message: 'User deleted successfully'
  });
}));

module.exports = router;