import { Routes, Route } from 'react-router-dom';
import { Layout } from './components/Layout';
import Dashboard from './pages/Dashboard';
import AllRequests from './pages/AllRequests';

function App() {
  return (
    <Routes>
      {/* The Layout wraps all these routes */}
      <Route path="/" element={<Layout />}>
        <Route index element={<Dashboard />} />
        <Route path="requests" element={<AllRequests />} />
        
        {/* Placeholder pages for buttons that don't have code yet */}
        <Route path="map" element={<div className="p-8 text-slate-500">Map Full View (Coming Soon)</div>} />
        <Route path="officers" element={<div className="p-8 text-slate-500">Officer Management (Coming Soon)</div>} />
        <Route path="settings" element={<div className="p-8 text-slate-500">System Settings (Coming Soon)</div>} />
      </Route>
    </Routes>
  );
}

export default App;