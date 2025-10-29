/**  
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 *   Route Declarations
 *      ./web/src/Routes.jsx
 * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 * 
 */

// import { StrictMode } from 'react'
// import { createRoot } from 'react-dom/client'
// import { BrowserRouter } from 'react-router-dom'
// import App from './App.jsx'
// import './styles/normalize.css'
// import './styles/global.css'

// createRoot(document.getElementById('root')).render(
//     <StrictMode>
//         <BrowserRouter>
//             <App />
//         </BrowserRouter>
//     </StrictMode>,
// )

import { Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import Test from './pages/Test'
import JsonData from './components/jsonData'

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/test" element={<Test />} />
      <Route path="/api/*" element={<JsonData />} />
    </Routes>
  )
}

export default AppRoutes