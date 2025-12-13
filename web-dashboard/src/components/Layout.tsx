import React from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Sidebar } from './SideBar';

export const Layout: React.FC = () => {
  const location = useLocation();
  
  // Extract the current path (e.g., 'dashboard' from '/dashboard') to highlight the button
  // Default to 'dashboard' if path is '/'
  const currentPath = location.pathname === '/' ? 'dashboard' : location.pathname.substring(1);

  return (
    <div className="flex h-screen bg-slate-950 text-slate-100 overflow-hidden font-sans">
      {/* 1. Sidebar is rendered ONCE here */}
      <Sidebar activeView={currentPath} />

      {/* 2. Content Area */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* The <Outlet /> renders the specific page (Dashboard or AllRequests) */}
        <Outlet />
      </div>
    </div>
  );
};