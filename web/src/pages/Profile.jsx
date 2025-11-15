// ./web/src/pages/Profile.jsx
import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext.jsx'
import '../styles/global.css'

const API_BASE = 'http://localhost:3001'

function Profile() {
  const { user: authUser, logout } = useAuth()
  const [user, setUser] = useState(null)
  const [editing, setEditing] = useState(false)
  const [formData, setFormData] = useState({
    username: '',
    email: ''
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const navigate = useNavigate()

  useEffect(() => {
    fetchProfile()
  }, [])

  const fetchProfile = async () => {
    try {
      const res = await fetch(`${API_BASE}/api/users/me`, {
        credentials: 'include'
      })

      if (!res.ok) {
        throw new Error('Failed to fetch profile')
      }

      const info = await res.json()
      console.log('Fetched profile data:', info.data)
      setUser(info.data)
      setFormData({
        username: info.data.username,
        email: info.data.email
      })
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  const handleUpdate = async (e) => {
    e.preventDefault()
    setError('')
    setSuccess('')

    try {
      const res = await fetch(`${API_BASE}/api/users/me`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(formData)
      })

      if (!res.ok) {
        const data = await res.json()
        throw new Error(data.message || 'Update failed')
      }

      const data = await res.json()
      setUser(data)
      setEditing(false)
      setSuccess('Profile updated successfully')
    } catch (err) {
      setError(err.message)
    }
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete your account? This cannot be undone.')) {
      return
    }

    try {
      const res = await fetch(`${API_BASE}/api/users/me`, {
        method: 'DELETE',
        credentials: 'include'
      })

      if (!res.ok) {
        throw new Error('Delete failed')
      }

      await logout()
      navigate('/')
    } catch (err) {
      setError(err.message)
    }
  }

  if (loading) return <div className="loading">Loading profile...</div>
  if (error && !user) return <div className="error">{error}</div>

  return (
    <div className="form-container">
      <h1>Profile</h1>
      
      {success && <div className="success">{success}</div>}
      {error && <div className="error">{error}</div>}

      {!editing ? (
        <div className="profile-view">
          <p><strong>Username:</strong> {user.username}</p>
          <p><strong>Email:</strong> {user.email}</p>
          <p><strong>ID:</strong> {user.user_id}</p>
          <p><strong>Created:</strong> {new Date(user.created_at).toLocaleString()}</p>
          
          <div className="button-group">
            <button onClick={() => setEditing(true)}>Edit Profile</button>
            <button onClick={handleDelete} className="danger">Delete Account</button>
          </div>
        </div>
      ) : (
        <form onSubmit={handleUpdate}>
          <div className="form-group">
            <label htmlFor="username">Username</label>
            <input
              type="text"
              id="username"
              name="username"
              value={formData.username}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
            />
          </div>

          <div className="button-group">
            <button type="submit">Save Changes</button>
            <button type="button" onClick={() => setEditing(false)}>Cancel</button>
          </div>
        </form>
      )}
    </div>
  )
}

export default Profile