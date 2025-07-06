import { Link } from 'react-router-dom'
import AppRoutes from './Routes'
import './App.css'

function App() {
  return (
    <div className="App">
      <nav style={{ padding: '1rem', borderBottom: '1px solid #ccc' }}>
        <Link to="/" style={{ marginRight: '1rem' }}>Home</Link>
        <Link to="/test" style={{ marginRight: '1rem' }}>API Test</Link>
      </nav>
      
      <main>
        <AppRoutes />
      </main>
    </div>
  )
}

export default App