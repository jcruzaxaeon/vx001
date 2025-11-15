/**  
 *   Application Entry Point #([ ] title phrasing/naming ???)
 *   @file ./web/src/App.jsx
 *   @todo [ ] fix(web): fix logout button on navbar
 * 
 */

import { Link, useNavigate } from 'react-router-dom'
import { useState, useEffect } from 'react' // ?[ ]
import AppRoutes from './Routes.jsx'
import { api } from './utils/api.js'
import { useAuth } from './contexts/AuthContext.jsx'
import './styles/global.css'
import './styles/normalize.css'

function App() {
    // const [user, setUser] = useState(null)
    // const [loading, setLoading] = useState(true)

    const { user, loading, logout } = useAuth()
    const navigate = useNavigate()

    const handleLogout = async () => {
        try {
            await logout()
            navigate('/')
        } catch (err) {
            console.error('Logout failed:', err)
        }
    }
    
    // const checkAuth = async () => {
    //     try {
    //         const response = await api.get('/api/auth/me')
    //         setUser(response.data)
    //     } catch (err) {
    //         // console.log('Authenticated user:', data)
    //         if (err.status === 401) {
    //             setUser(null)
    //         } else {
    //             console.error('Auth check failed:', err)
    //         }
    //     } finally {
    //         setLoading(false)
    //     }
    // }

    // const handleLogout = async () => {
    //     try {
    //         await api.post('/api/auth/logout')
    //         setUser(null)
    //         window.location.href = '/'
    //     } catch (err) {
    //         console.error('Logout failed:', err)
    //     }
    // }

    if (loading) return <div className="loading">Loading...</div> 

    return (
        <div className="App">
            <nav>
            <div className="nav-left">
                <Link to="/">Home</Link>
                <Link to="/test">API Test</Link>
                {user && <Link to="/users">Users</Link>}
            </div>
            <div className="nav-right">
                {user ? (
                <>
                    <Link to="/profile">Profile ({user.username})</Link>
                    <button onClick={handleLogout}>Logout</button>
                </>
                ) : (
                <>
                    <Link to="/login">Login</Link>
                    <Link to="/register">Register</Link>
                </>
                )}
            </div>
            </nav>
            
            <main>
            <AppRoutes />
            </main>
        </div>
    )
    }

export default App