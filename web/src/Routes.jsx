/**  
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 *   Route Declarations
 *      ./web/src/Routes.jsx
 * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 * 
 */

import { Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import Test from './pages/Test'
import Register from './pages/Register'
import Login from './pages/Login'
// import Users from './pages/Users'
// import Profile from './pages/Profile'
import JsonData from './components/jsonData'

function AppRoutes() {
    return (
    <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/test" element={<Test />} />
        <Route path="/register" element={<Register />} />
        <Route path="/login" element={<Login />} />
        {/* <Route path="/users" element={<Users />} />
        <Route path="/profile" element={<Profile />} /> */}
        <Route path="/api/*" element={<JsonData />} />
    </Routes>
    )
}

export default AppRoutes