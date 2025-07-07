import { Link } from 'react-router-dom'
import AppRoutes from './Routes'
import './styles/normalize.css'

function App() {
  return (
    <div className="App">
      <nav>
        <Link to="/">Home</Link>
        <Link to="/test">API Test</Link>
      </nav>
      
      <main>
        <AppRoutes />
      </main>
    </div>
  )
}

export default App