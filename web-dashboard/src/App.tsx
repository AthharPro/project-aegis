import { Routes, Route, Navigate } from 'react-router-dom';
import { Layout } from './components/Layout';
import Dashboard from './pages/Dashboard';
import AllRequests from './pages/AllRequests';
import Dispatchers from './pages/Dispatchers';
import CompletedRequests from './pages/CompletedRequests';
import Login from './pages/Login';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { Loader2 } from 'lucide-react';

// 1. Create a wrapper component to protect routes
// It checks if a session exists. If not, it kicks the user to /login
const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { session, loading } = useAuth();

  // Show a loading spinner while Supabase checks the session
  if (loading) {
    return (
      <div className="h-screen bg-slate-950 flex items-center justify-center text-slate-500 gap-2">
        <Loader2 className="animate-spin" /> Verifying Access...
      </div>
    );
  }

  if (!session) {
    return <Navigate to="/login" replace />;
  }

  return children;
};

function App() {
  return (
    // 2. Wrap the entire application in AuthProvider so auth state is global
    <AuthProvider>
      <Routes>

        {/* PUBLIC ROUTE: Login Page */}
        <Route path="/login" element={<Login />} />

        {/* PROTECTED ROUTES: Wrapped in ProtectedRoute + Layout */}
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <Layout />
            </ProtectedRoute>
          }
        >
          {/* These are the pages only logged-in admins can see */}
          <Route index element={<Dashboard />} />
          <Route path="requests" element={<AllRequests />} />
          <Route path="completed-requests" element={<CompletedRequests />} />
          <Route path="dispatchers" element={<Dispatchers />} />

          {/* Placeholders */}
          <Route path="map" element={<div className="p-8 text-slate-500">Map Full View (Coming Soon)</div>} />
          {/* <Route path="settings" element={<div className="p-8 text-slate-500">System Settings (Coming Soon)</div>} /> */}
        </Route>

      </Routes>
    </AuthProvider>
  );
}

export default App;