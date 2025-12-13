import Dashboard from './pages/Dashboard';

function App() {
  return (
    // We don't need a Router here because Dashboard.tsx handles 
    // switching between "Map" and "List" views internally.
    <Dashboard />
  );
}

export default App;