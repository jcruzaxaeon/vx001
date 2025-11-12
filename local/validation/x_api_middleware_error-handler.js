// api/middleware/error-handler.js

// Custom error class for application errors
class AppError extends Error {
  constructor(message, statusCode = 500, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    
    Error.captureStackTrace(this, this.constructor);
  }
}

// Database error handler
const handleDatabaseError = (error) => {
  console.error('Database Error:', error);
  
  // Sequelize validation errors
  if (error.name === 'SequelizeValidationError') {
    const messages = error.errors.map(err => err.message);
    return new AppError(`Validation error: ${messages.join(', ')}`, 400);
  }
  
  // Sequelize unique constraint errors
  if (error.name === 'SequelizeUniqueConstraintError') {
    const field = error.errors[0]?.path || 'field';
    return new AppError(`${field} already exists`, 409);
  }
  
  // Sequelize foreign key constraint errors
  if (error.name === 'SequelizeForeignKeyConstraintError') {
    return new AppError('Invalid reference to related record', 400);
  }
  
  // Generic database error
  return new AppError('Database operation failed', 500);
};

// Global error handling middleware
const globalErrorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error for debugging
  console.error('Error Stack:', err.stack);

  // Handle specific error types
  if (err.name === 'CastError') {
    error = new AppError('Invalid ID format', 400);
  } else if (err.name?.startsWith('Sequelize')) {
    error = handleDatabaseError(err);
  } else if (!err.isOperational) {
    // Programming errors - don't leak details
    error = new AppError('Something went wrong', 500);
  }

  // Send error response
  const response = {
    success: false,
    message: error.message || 'Internal server error'
  };

  // Include error details in development
  if (process.env.NODE_ENV === 'development') {
    response.error = error;
    response.stack = err.stack;
  }

  res.status(error.statusCode || 500).json(response);
};

// Async error wrapper
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// 404 handler
const notFoundHandler = (req, res, next) => {
  const error = new AppError(`Route ${req.originalUrl} not found`, 404);
  next(error);
};

module.exports = {
  AppError,
  globalErrorHandler,
  asyncHandler,
  notFoundHandler
};