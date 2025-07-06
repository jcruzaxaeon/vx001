// ==== web/src/Routes.jsx ====
import { Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import Test from './pages/Test'

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/test" element={<Test />} />
    </Routes>
  )
}

export default AppRoutes