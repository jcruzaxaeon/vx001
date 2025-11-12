// Custom validation helpers
const isEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const isEmpty = (value) => {
  return value === undefined || value === null || value.toString().trim() === '';
};

const isString = (value) => {
  return typeof value === 'string';
};

// Validation functions
const validateUserCreate = (data) => {
  const errors = [];
  const { email, password, firstName, lastName } = data;

  // Email validation
  if (isEmpty(email)) {
    errors.push({ field: 'email', message: 'Email is required' });
  } else if (!isString(email)) {
    errors.push({ field: 'email', message: 'Email must be a string' });
  } else if (!isEmail(email.trim())) {
    errors.push({ field: 'email', message: 'Valid email is required' });
  }

  // Password validation
  if (isEmpty(password)) {
    errors.push({ field: 'password', message: 'Password is required' });
  } else if (!isString(password)) {
    errors.push({ field: 'password', message: 'Password must be a string' });
  } else if (password.length < 6) {
    errors.push({ field: 'password', message: 'Password must be at least 6 characters' });
  }

  // First name validation
  if (isEmpty(firstName)) {
    errors.push({ field: 'firstName', message: 'First name is required' });
  } else if (!isString(firstName)) {
    errors.push({ field: 'firstName', message: 'First name must be a string' });
  } else if (firstName.trim().length === 0) {
    errors.push({ field: 'firstName', message: 'First name cannot be empty' });
  }

  // Last name validation
  if (isEmpty(lastName)) {
    errors.push({ field: 'lastName', message: 'Last name is required' });
  } else if (!isString(lastName)) {
    errors.push({ field: 'lastName', message: 'Last name must be a string' });
  } else if (lastName.trim().length === 0) {
    errors.push({ field: 'lastName', message: 'Last name cannot be empty' });
  }

  return errors;
};

const validateUserUpdate = (data) => {
  const errors = [];
  const { email, firstName, lastName } = data;

  // Email validation (optional for updates)
  if (email !== undefined) {
    if (!isString(email)) {
      errors.push({ field: 'email', message: 'Email must be a string' });
    } else if (!isEmail(email.trim())) {
      errors.push({ field: 'email', message: 'Valid email is required' });
    }
  }

  // First name validation (optional for updates)
  if (firstName !== undefined) {
    if (!isString(firstName)) {
      errors.push({ field: 'firstName', message: 'First name must be a string' });
    } else if (firstName.trim().length === 0) {
      errors.push({ field: 'firstName', message: 'First name cannot be empty' });
    }
  }

  // Last name validation (optional for updates)
  if (lastName !== undefined) {
    if (!isString(lastName)) {
      errors.push({ field: 'lastName', message: 'Last name must be a string' });
    } else if (lastName.trim().length === 0) {
      errors.push({ field: 'lastName', message: 'Last name cannot be empty' });
    }
  }

  return errors;
};

// Middleware generators
const validateUserCreateMiddleware = (req, res, next) => {
  const errors = validateUserCreate(req.body);
  
  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors
    });
  }
  
  // Trim and normalize data
  if (req.body.email) req.body.email = req.body.email.trim().toLowerCase();
  if (req.body.firstName) req.body.firstName = req.body.firstName.trim();
  if (req.body.lastName) req.body.lastName = req.body.lastName.trim();
  
  next();
};

const validateUserUpdateMiddleware = (req, res, next) => {
  const errors = validateUserUpdate(req.body);
  
  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors
    });
  }
  
  // Trim and normalize data
  if (req.body.email) req.body.email = req.body.email.trim().toLowerCase();
  if (req.body.firstName) req.body.firstName = req.body.firstName.trim();
  if (req.body.lastName) req.body.lastName = req.body.lastName.trim();
  
  next();
};

module.exports = {
  validateUserCreate,
  validateUserUpdate,
  validateUserCreateMiddleware,
  validateUserUpdateMiddleware,
  // Export helpers for testing or reuse
  isEmail,
  isEmpty,
  isString
};