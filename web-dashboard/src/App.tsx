import { Routes, Route } from 'react-router-dom';
import { Layout } from './components/Layout';
import Dashboard from './pages/Dashboard';
import AllRequests from './pages/AllRequests';
import Dispatchers from './pages/Dispatchers';
import CompletedRequests from './pages/CompletedRequests';
import { useEffect } from 'react';
import { supabase } from './services/supabaseClient';

function App() {
  useEffect(() => {
    const autoLogin = async () => {
      const { data: { session } } = await supabase.auth.getSession()

      // Only login if we aren't already logged in
      if (!session) {
        console.log("⚡ Auto-logging in Dashboard...")
        const { error } = await supabase.auth.signInWithPassword({
          email: 'theayazahamed@gmail.com',
          password: 'putmeout'
        })
        if (error) console.error("Login failed:", error)
      }
    }

    autoLogin()
  }, [])

  return (
    <Routes>
      {/* The Layout wraps all these routes */}
      <Route path="/" element={<Layout />}>
        <Route index element={<Dashboard />} />
        <Route path="requests" element={<AllRequests />} />
        <Route path="completed-requests" element={<CompletedRequests />} />
        <Route path="dispatchers" element={<Dispatchers />} />

        {/* Placeholder pages for buttons that don't have code yet */}
        <Route path="map" element={<div className="p-8 text-slate-500">Map Full View (Coming Soon)</div>} />

        <Route path="settings" element={<div className="p-8 text-slate-500">System Settings (Coming Soon)</div>} />
      </Route>
    </Routes>
  );
}

export default App;