# Auth System Implementation 🔐

Let's build this step-by-step!

---

## Step 1: Install Dependencies

```bash
npm install express-session bcrypt
```

- `express-session` - Session management
- `bcrypt` - Password hashing

---

## Step 2: Session Middleware Setup

**File: `server.js` or `app.js` (your main server file)**

```javascript
const express = require('express');
const session = require('express-session');
const mysql = require('mysql2/promise');
require('dotenv').config();

const app = express();

// Parse JSON bodies
app.use(express.json());

// Session middleware - ADD THIS BEFORE YOUR ROUTES
app.use(session({
  secret: process.env.SESSION_SECRET, // Add to .env: SESSION_SECRET=your-random-32-char-string
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,      // Can't access via JavaScript
    secure: false,       // Set to true when using HTTPS in production
    sameSite: 'strict',  // CSRF protection
    maxAge: 1000 * 60 * 60 * 24 // 24 hours
  }
}));

// Your existing MySQL connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// ... rest of your code
```

**Add to `.env`:**
```env
SESSION_SECRET=generate-a-long-random-string-here-min-32-chars
```

Generate random string in terminal:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

## Step 3: Auth Middleware (Protect Routes)

**File: `middleware/auth.js` (create new file)**

```javascript
// Middleware to check if user is authenticated
function requireAuth(req, res, next) {
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

// Middleware to check if user owns the resource
function requireOwnership(req, res, next) {
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

module.exports = { requireAuth, requireOwnership };
```

---

## Step 4: Auth Routes (Login, Logout, Check Session)

**File: `routes/auth.js` (create new file)**

```javascript
const express = require('express');
const bcrypt = require('bcrypt');
const router = express.Router();

// Assumes you pass the db pool when mounting this router
// We'll show how below

// POST /api/auth/register - Create new user
router.post('/register', async (req, res) => {
  const { email, password, username } = req.body;
  
  // Validation
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }
  
  if (password.length < 8) {
    return res.status(400).json({ error: 'Password must be at least 8 characters' });
  }
  
  try {
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Insert user
    const [result] = await req.db.query(
      'INSERT INTO users (email, password, username) VALUES (?, ?, ?)',
      [email, hashedPassword, username]
    );
    
    // Auto-login after registration
    req.session.userId = result.insertId;
    req.session.email = email;
    
    res.status(201).json({
      message: 'User created successfully',
      user: {
        id: result.insertId,
        email,
        username
      }
    });
    
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Email already exists' });
    }
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// POST /api/auth/login - Login user
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }
  
  try {
    // Find user
    const [users] = await req.db.query(
      'SELECT id, email, password, username FROM users WHERE email = ?',
      [email]
    );
    
    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    
    const user = users[0];
    
    // Verify password
    const validPassword = await bcrypt.compare(password, user.password);
    
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    
    // Create session
    req.session.userId = user.id;
    req.session.email = user.email;
    
    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        username: user.username
      }
    });
    
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// POST /api/auth/logout - Logout user
router.post('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ error: 'Logout failed' });
    }
    
    res.clearCookie('connect.sid'); // Default session cookie name
    res.json({ message: 'Logout successful' });
  });
});

// GET /api/auth/me - Get current user (check if logged in)
router.get('/me', async (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'Not authenticated' });
  }
  
  try {
    const [users] = await req.db.query(
      'SELECT id, email, username, created_at FROM users WHERE id = ?',
      [req.session.userId]
    );
    
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json({ user: users[0] });
    
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

module.exports = router;
```

---

## Step 5: Update User Routes (Protect with Auth)

**File: `routes/users.js` (update your existing file)**

```javascript
const express = require('express');
const bcrypt = require('bcrypt');
const { requireAuth, requireOwnership } = require('../middleware/auth');
const router = express.Router();

// GET /api/users - List all users (PROTECTED)
router.get('/', requireAuth, async (req, res) => {
  try {
    const [users] = await req.db.query(
      'SELECT id, email, username, created_at FROM users'
    );
    res.json(users);
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Failed to get users' });
  }
});

// GET /api/users/:id - Get single user (PROTECTED + OWNERSHIP)
router.get('/:id', requireAuth, requireOwnership, async (req, res) => {
  try {
    const [users] = await req.db.query(
      'SELECT id, email, username, created_at FROM users WHERE id = ?',
      [req.params.id]
    );
    
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(users[0]);
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

// PUT /api/users/:id - Update user (PROTECTED + OWNERSHIP)
router.put('/:id', requireAuth, requireOwnership, async (req, res) => {
  const { email, username, password } = req.body;
  const updates = [];
  const values = [];
  
  if (email) {
    updates.push('email = ?');
    values.push(email);
  }
  
  if (username) {
    updates.push('username = ?');
    values.push(username);
  }
  
  if (password) {
    if (password.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    updates.push('password = ?');
    values.push(hashedPassword);
  }
  
  if (updates.length === 0) {
    return res.status(400).json({ error: 'No fields to update' });
  }
  
  values.push(req.params.id);
  
  try {
    await req.db.query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    
    res.json({ message: 'User updated successfully' });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Email already exists' });
    }
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Failed to update user' });
  }
});

// DELETE /api/users/:id - Delete user (PROTECTED + OWNERSHIP)
router.delete('/:id', requireAuth, requireOwnership, async (req, res) => {
  try {
    await req.db.query('DELETE FROM users WHERE id = ?', [req.params.id]);
    
    // Destroy session after deleting account
    req.session.destroy();
    
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ error: 'Failed to delete user' });
  }
});

module.exports = router;
```

---

## Step 6: Wire Everything Together

**File: `server.js` (update your main file)**

```javascript
const express = require('express');
const session = require('express-session');
const mysql = require('mysql2/promise');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Session middleware
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: false, // true in production with HTTPS
    sameSite: 'strict',
    maxAge: 1000 * 60 * 60 * 24 // 24 hours
  }
}));

// Database connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Attach db to request object
app.use((req, res, next) => {
  req.db = pool;
  next();
});

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## Step 7: Update Your Database Schema

Make sure your users table has a password column:

```sql
ALTER TABLE users 
MODIFY COLUMN password VARCHAR(255) NOT NULL;

-- If you don't have a username column yet:
ALTER TABLE users 
ADD COLUMN username VARCHAR(50) UNIQUE;
```

---

## Step 8: Test It! 🧪

### Test with curl:

```bash
# 1. Register a new user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","username":"testuser"}' \
  -c cookies.txt

# 2. Check if you're logged in
curl -X GET http://localhost:3000/api/auth/me \
  -b cookies.txt

# 3. Logout
curl -X POST http://localhost:3000/api/auth/logout \
  -b cookies.txt \
  -c cookies.txt

# 4. Try to access protected route (should fail)
curl -X GET http://localhost:3000/api/users \
  -b cookies.txt

# 5. Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  -c cookies.txt

# 6. Access protected route (should work now)
curl -X GET http://localhost:3000/api/users \
  -b cookies.txt

# 7. Update your own user (should work)
curl -X PUT http://localhost:3000/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"username":"newusername"}' \
  -b cookies.txt

# 8. Try to update someone else's user (should fail with 403)
curl -X PUT http://localhost:3000/api/users/2 \
  -H "Content-Type: application/json" \
  -d '{"username":"hacker"}' \
  -b cookies.txt
```

**Note:** The `-c cookies.txt` saves cookies, `-b cookies.txt` sends them back.

---

## What You Just Built ✨

✅ **Password hashing** with bcrypt  
✅ **Session-based authentication**  
✅ **Login/logout/register endpoints**  
✅ **Protected routes** (must be logged in)  
✅ **Ownership validation** (can only edit your own data)  
✅ **Secure cookies** (httpOnly, sameSite)  
✅ **Auto-login after registration**  

---

## Next Steps

1. **Test everything** with the curl commands above
2. **Check for errors** - let me know what breaks!
3. **Build a simple login/register HTML page** (Phase 2)

Questions? Issues? Let me know what happens when you test it! 🚀