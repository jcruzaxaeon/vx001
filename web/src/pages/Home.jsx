// ==== web/src/pages/Home.jsx ====
function Home() {
  return (
    <div>
      <h1>MySQL-ERN App</h1>
      <p>Welcome to your fullstack application!</p>
      <p>This is your main application. Use the navigation above to access different sections.</p>
      
      <div>
        <h2>Available Routes:</h2>
        <ul>
          <li><strong>/</strong> - Home (this page)</li>
          <li><strong>/test</strong> - API Testing Interface</li>
        </ul>
      </div>
    </div>
  )
}

export default Home