// ==== web/src/components/Test.jsx ====
import { useState } from 'react'
import axios from 'axios'

const API_BASE = 'http://localhost:3001'

// Configure axios defaults
axios.defaults.baseURL = API_BASE
axios.defaults.headers.common['Content-Type'] = 'application/json'

function Test() {
  const [healthResults, setHealthResults] = useState('Click a button to test API connection...')
  const [getResults, setGetResults] = useState('No data yet...')
  const [createResults, setCreateResults] = useState('No data yet...')
  const [updateResults, setUpdateResults] = useState('No data yet...')
  
  const [userId, setUserId] = useState('')
  const [newEmail, setNewEmail] = useState('')
  const [newUsername, setNewUsername] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [updateUserId, setUpdateUserId] = useState('')

  // Utility function to display results
  const displayResult = (setter, data) => {
    setter(JSON.stringify(data, null, 2))
  }

  // Health check functions
  const checkHealth = async () => {
    try {
      const response = await axios.get('/api/health')
      displayResult(setHealthResults, response.data)
    } catch (error) {
        console.log('Health check error:', error)
        displayResult(setHealthResults, {
        error: error.response?.data?.error || error.message 
      })
    }
  }

  const checkBasicRoute = async () => {
    try {
      const response = await axios.get('/')
      displayResult(setHealthResults, { 
        message: response.data, 
        status: response.status 
      })
    } catch (error) {
      displayResult(setHealthResults, { 
        error: error.response?.data?.error || error.message 
      })
    }
  }

  // Get users functions
  const getAllUsers = async () => {
    try {
      const response = await axios.get('/api/users')
      displayResult(setGetResults, response.data)
    } catch (error) {
      displayResult(setGetResults, { 
        error: error.response?.data?.error || error.message 
      })
    }
  }

  const getUserById = async () => {
    if (!userId) {
      alert('Please enter a User ID');
      return;
    }

    try {
      const response = await axios.get(`/api/users/${userId}`);
      displayResult(setGetResults, response.data);
    } catch (error) {
      // displayResult(setGetResults, { 
      //   error: error.response?.data?.error || error.message 
      // })
      const errors = error.response?.data || [];
      // errors.map( err => `${err.name}: ${err.message}`);
      displayResult(setGetResults, {errors});
    }
  }

  // Create user functions
  const createUser = async () => {
    if (!newEmail || !newPassword) {
      alert('Email and password hash are required')
      return
    }

    try {
      const response = await axios.post('/api/users', {
        email: newEmail,
        username: newUsername || null,
        password: newPassword
      })

      displayResult(setCreateResults, response.data)

      // Clear form if successful
      setNewEmail('')
      setNewUsername('')
      setNewPassword('')
    } catch (error) {
      displayResult(setCreateResults, { 
        error: error.response?.data?.error || error.message 
      })
      // displayResult(setCreateResults, {error})
    }
  }

  const createRandomUser = async () => {
    const timestamp = Date.now()
    const randomUser = {
      email: `test${timestamp}@example.com`,
      username: `user${timestamp}`,
      password: `passWord_${timestamp}`
    }
    console.log('Creating random user:', randomUser)

    try {
      const response = await axios.post('/api/users', randomUser)
      displayResult(setCreateResults, response.data)
    } catch (error) {
      displayResult(setCreateResults, { 
        error: error.response?.data?.error || error.message 
      })
    }
  }

  // Delete user function
  const deleteUser = async () => {
    if (!updateUserId) {
      alert('Please enter a User ID')
      return
    }

    if (!confirm(`Are you sure you want to delete user ${updateUserId}?`)) {
      return
    }

    try {
      await axios.delete(`/api/users/${updateUserId}`)
      displayResult(setUpdateResults, { message: 'User deleted successfully' })
      setUpdateUserId('')
    } catch (error) {
      displayResult(setUpdateResults, { 
        error: error.response?.data?.error || error.message 
      })
    }
  }

  return (
    <div className="container">
      <h1>🧪 User API Test Client (React)</h1>
      
      {/* API Health Check */}
      <section className="section">
        <h3>🏥 API Health Check</h3>
        <div className="controls">
          <button onClick={checkHealth}>Check API Health</button>
          <button onClick={checkBasicRoute}>Test Basic Route</button>
        </div>
        <pre className="results">{healthResults}</pre>
      </section>

      {/* Get Users */}
      <section className="section">
        <h3>👥 Get Users</h3>
        <div className="controls">
          <button onClick={getAllUsers}>Get All Users</button>
          <button onClick={getUserById}>Get User by ID</button>
          <input 
            type="text" 
            value={userId}
            onChange={(e) => setUserId(e.target.value)}
            placeholder="Enter User ID" 
            className="input-small"
          />
        </div>
        <pre className="results">{getResults}</pre>
      </section>

      {/* Create User */}
      <section className="section">
        <h3>➕ Create User</h3>
        <div className="form-grid">
          <div className="form-group">
            <label htmlFor="newEmail">Email:</label>
            <input 
              type="email" 
              id="newEmail"
              value={newEmail}
              onChange={(e) => setNewEmail(e.target.value)}
              placeholder="user@example.com"
            />
          </div>
          <div className="form-group">
            <label htmlFor="newUsername">Username:</label>
            <input 
              type="text" 
              id="newUsername"
              value={newUsername}
              onChange={(e) => setNewUsername(e.target.value)}
              placeholder="username"
            />
          </div>
        </div>
        <div className="form-group">
          <label htmlFor="newPassword">Password Hash:</label>
          <input 
            type="text" 
            id="newPassword"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
            placeholder="hashed_password_here"
          />
        </div>
        <div className="controls">
          <button onClick={createUser}>Create User</button>
          <button onClick={createRandomUser}>Create Random Test User</button>
        </div>
        <pre className="results">{createResults}</pre>
      </section>

      {/* Update/Delete User */}
      <section className="section">
        <h3>✏️ Update/Delete User</h3>
        <div className="delete-controls">
          <label>User ID:</label>
          <input 
            type="text" 
            value={updateUserId}
            onChange={(e) => setUpdateUserId(e.target.value)}
            placeholder="Enter User ID"
          />
          <button onClick={deleteUser} className="danger">Delete User</button>
        </div>
        <pre className="results">{updateResults}</pre>
      </section>
    </div>
  )
}

export default Test