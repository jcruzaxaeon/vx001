/**
 * Authentication Middleware
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>100
 * @file api/middleware/authentication.js
 * @description Middleware to handle user authentication and authorization
 * @todo update requireAuth, requireOwnership to standard error format
 */

/**
 * REQUIRE AUTHENTICATION
 * 
 * @param {*} req 
 * @param {*} res 
 * @param {*} next 
 * @returns 
 */
export const requireAuth = (req, res, next) => {
  // console.log(req.session);
  if (req.session && req.session.userId) {
    // User is logged in
    return next();
  }
  
  // User not logged in
  return res.status(401).json({ 
    error: 'Authentication required',
    message: 'Please log in to access this resource'
  });
}

/**
 * REQUIRE OWNERSHIP
 * 
 * @param {*} req 
 * @param {*} res 
 * @param {*} next 
 * @returns 
 */
export const requireOwnership = (req, res, next) =>{
  const requestedUserId = parseInt(req.params.id || req.params.userId);
  const loggedInUserId = req.session.userId;
  
  if (loggedInUserId !== requestedUserId) {
    return res.status(403).json({ 
      error: 'Forbidden',
      message: 'You can only access your own resources'
    });
  }
  
  next();
}

// module.exports = { requireAuth, requireOwnership };