import React from 'react';
import { Link } from 'react-router-dom';
import { Radio, LayoutDashboard, MapPinned, Users, Settings, Database } from 'lucide-react';

interface SidebarProps {
    activeView: string;
}

export const Sidebar: React.FC<SidebarProps> = ({ activeView }) => {
    const menuItems = [
        { id: 'dashboard', path: '/', icon: LayoutDashboard, label: 'Dashboard' },
        { id: 'requests', path: '/requests', icon: Database, label: 'All Requests' },
        { id: 'completed-requests', path: '/completed-requests', icon: Database, label: 'Completed Requests' },
        { id: 'map', path: '/map', icon: MapPinned, label: 'Map View' },
        { id: 'dispatchers', path: '/dispatchers', icon: Users, label: 'Dispatchers' },
        { id: 'settings', path: '/settings', icon: Settings, label: 'Settings' }
    ];

    return (
        <div className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col flex-shrink-0">
            <div className="p-6 border-b border-slate-800">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-slate-600 rounded-lg flex items-center justify-center shadow-lg shadow-red-900/20">
                        <Radio className="w-6 h-6 text-white" />
                    </div>
                    <div>
                        <div className="font-bold text-lg tracking-tight">HQ COMMAND</div>
                        <div className="text-xs text-slate-500 uppercase tracking-wider font-semibold">Rescue Ops</div>
                    </div>
                </div>
            </div>

            <nav className="flex-1 p-4 space-y-2">
                {menuItems.map(item => (
                    <Link
                        key={item.id}
                        to={item.path}
                        className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200 ${activeView === item.id
                                ? 'bg-slate-600 text-white shadow-md shadow-red-900/30'
                                : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
                            }`}
                    >
                        <item.icon className="w-5 h-5" />
                        <span className="font-medium">{item.label}</span>
                    </Link>
                ))}
            </nav>

            <div className="p-4 border-t border-slate-800">
                <div className="text-xs text-slate-500 font-mono">v2.4.1 • Secure Link</div>
            </div>
        </div>
    );
};