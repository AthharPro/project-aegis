import React from 'react';
import { Radio, LayoutDashboard, MapPinned, Users, Settings } from 'lucide-react';

export const Sidebar: React.FC<{ activeView: string, setActiveView: (id: string) => void }> = ({ activeView, setActiveView }) => {
  const menuItems = [
    { id: 'dashboard', icon: LayoutDashboard, label: 'Dashboard' },
    { id: 'map', icon: MapPinned, label: 'Map View' },
    { id: 'officers', icon: Users, label: 'Officers' },
    { id: 'settings', icon: Settings, label: 'Settings' }
  ];

  return (
    <div className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col">
      <div className="p-6 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-red-600 rounded-lg flex items-center justify-center">
            <Radio className="w-6 h-6 text-white" />
          </div>
          <div>
            <div className="font-bold text-lg">HQ COMMAND</div>
            <div className="text-xs text-slate-500 uppercase tracking-wider">Rescue Ops</div>
          </div>
        </div>
      </div>

      <nav className="flex-1 p-4 space-y-2">
        {menuItems.map(item => (
          <button
            key={item.id}
            onClick={() => setActiveView(item.id)}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
              activeView === item.id ? 'bg-red-600 text-white' : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
            }`}
          >
            <item.icon className="w-5 h-5" />
            <span className="font-medium">{item.label}</span>
          </button>
        ))}
      </nav>
      
      <div className="p-4 border-t border-slate-800">
         <div className="text-xs text-slate-500 space-y-1">
           <div className="font-mono">v2.4.1</div>
           <div>© 2025 Army HQ</div>
         </div>
      </div>
    </div>
  );
};