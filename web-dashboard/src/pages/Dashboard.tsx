import React, { useState } from 'react';
import { Activity, Wifi, WifiOff, Users, AlertTriangle, Clock } from 'lucide-react';
import { useVictims } from '../hooks/UseVictim';
import { StatCard } from '../components/StatCard';
import { VictimRow } from '../components/VictimRow';
import { MapView } from '../components/MapView';
import { Sidebar } from '../components/SideBar';

const Dashboard: React.FC = () => {
  const { victims, isConnected, isLoading } = useVictims();
  const [activeView, setActiveView] = useState('dashboard');

  const stats = {
    total: victims.length,
    critical: victims.filter(v => v.injury_status === 'Critical').length,
    stable: victims.filter(v => v.injury_status === 'Stable').length,
    recentlyAdded: victims.filter(v => 
      new Date().getTime() - new Date(v.created_at).getTime() < 600000
    ).length
  };

  return (
    <div className="flex h-screen bg-slate-950 text-slate-100 overflow-hidden">
      <Sidebar activeView={activeView} setActiveView={setActiveView} />

      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Bar */}
        <div className="bg-slate-900 border-b border-slate-800 px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold">Rescue Operations Center</h1>
              <p className="text-sm text-slate-500">Real-time victim tracking and coordination</p>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2 bg-slate-800 px-4 py-2 rounded-lg">
                <Activity className="w-4 h-4 text-red-500 animate-pulse" />
                <span className="text-sm font-semibold text-red-500">LIVE</span>
              </div>
              <div className={`flex items-center gap-2 px-4 py-2 rounded-lg ${isConnected ? 'bg-emerald-500/20 text-emerald-400' : 'bg-red-500/20 text-red-400'}`}>
                {isConnected ? <Wifi className="w-4 h-4" /> : <WifiOff className="w-4 h-4" />}
                <span className="text-sm font-semibold">{isConnected ? 'CONNECTED' : 'OFFLINE'}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Dashboard Content */}
        <div className="flex-1 overflow-auto p-6">
          {isLoading ? (
            <div className="flex items-center justify-center h-full">
              <div className="text-center">
                <Activity className="w-12 h-12 text-red-500 animate-spin mx-auto mb-4" />
                <div className="text-slate-400">Establishing secure connection...</div>
              </div>
            </div>
          ) : (
            <div className="space-y-6">
              {/* Stats Row */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <StatCard icon={<Users className="w-4 h-4" />} label="Total Victims" value={stats.total} trend="All time" color="text-slate-100" />
                <StatCard icon={<AlertTriangle className="w-4 h-4" />} label="Critical" value={stats.critical} trend="Immediate attention" color="text-red-500" />
                <StatCard icon={<Activity className="w-4 h-4" />} label="Stable" value={stats.stable} trend="Monitored" color="text-emerald-500" />
                <StatCard icon={<Clock className="w-4 h-4" />} label="Recent Sync" value={stats.recentlyAdded} trend="Last 10 mins" color="text-amber-500" />
              </div>

              {/* Main Grid */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-[calc(100vh-280px)]">
                {/* Live Feed */}
                <div className="bg-slate-900/50 border border-slate-800 rounded-lg overflow-hidden flex flex-col">
                  <div className="bg-slate-900 border-b border-slate-800 p-4">
                    <h2 className="text-lg font-bold flex items-center gap-2">
                      <Activity className="w-5 h-5 text-red-500" />
                      Live Victim Feed
                    </h2>
                  </div>
                  <div className="flex-1 overflow-auto p-4 space-y-2">
                    {victims.length === 0 ? (
                      <div className="text-center text-slate-500 py-12">No victims reported yet</div>
                    ) : (
                      victims.map(victim => <VictimRow key={victim.id} victim={victim} />)
                    )}
                  </div>
                </div>

                {/* Map */}
                <div className="bg-slate-900/50 border border-slate-800 rounded-lg overflow-hidden">
                  <MapView victims={victims} />
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;