import React from 'react';
import { Activity, Wifi, WifiOff, Users, AlertTriangle, ShieldAlert } from 'lucide-react';
import { useIncidents } from '../hooks/UseVictim'; // Updated Hook
import { StatCard } from '../components/StatCard';
import { IncidentRow } from '../components/VictimRow'; // Updated Component
import { MapView } from '../components/MapView';

const Dashboard: React.FC = () => {
  const { incidents, isConnected, isLoading, updateStatus } = useIncidents();

  // --- Real-time Stats Calculation ---
  const stats = {
    totalReports: incidents.length,
    
    // Count "Critical" or "High" severity (Level 4 & 5)
    criticalIncidents: incidents.filter(i => i.severity >= 4).length,
    
    // Sum of all victims from all incidents
    totalVictims: incidents.reduce((acc, curr) => acc + curr.victim_count, 0),
    
    // Count active missions (anything not 'RESOLVED')
    activeMissions: incidents.filter(i => i.status !== 'RESOLVED').length
  };

  return (
    <div className="flex h-screen bg-slate-950 text-slate-100 overflow-hidden font-sans">

      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Bar */}
        <div className="bg-slate-900 border-b border-slate-800 px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold tracking-tight">Rescue Operations Center</h1>
              <p className="text-sm text-slate-500">Live Situation Awareness & Dispatch</p>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2 bg-slate-800 px-4 py-2 rounded-lg">
                <Activity className="w-4 h-4 text-red-500 animate-pulse" />
                <span className="text-sm font-semibold text-red-500">LIVE FEED</span>
              </div>
              <div className={`flex items-center gap-2 px-4 py-2 rounded-lg ${isConnected ? 'bg-emerald-500/20 text-emerald-400' : 'bg-red-500/20 text-red-400'}`}>
                {isConnected ? <Wifi className="w-4 h-4" /> : <WifiOff className="w-4 h-4" />}
                <span className="text-sm font-semibold">{isConnected ? 'ONLINE' : 'DISCONNECTED'}</span>
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
                <div className="text-slate-400">Establishing secure link to field units...</div>
              </div>
            </div>
          ) : (
            <div className="space-y-6">
              
              {/* Stats Row */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <StatCard 
                  icon={<ShieldAlert className="w-4 h-4" />} 
                  label="Total Reports" 
                  value={stats.totalReports} 
                  trend="All Time" 
                  color="text-slate-100" 
                />
                <StatCard 
                  icon={<AlertTriangle className="w-4 h-4" />} 
                  label="Critical Incidents" 
                  value={stats.criticalIncidents} 
                  trend="Level 4-5 Severity" 
                  color="text-red-500" 
                />
                <StatCard 
                  icon={<Users className="w-4 h-4" />} 
                  label="Total Victims" 
                  value={stats.totalVictims} 
                  trend="Confirmed on site" 
                  color="text-amber-500" 
                />
                <StatCard 
                  icon={<Activity className="w-4 h-4" />} 
                  label="Active Missions" 
                  value={stats.activeMissions} 
                  trend="Pending Resolution" 
                  color="text-blue-500" 
                />
              </div>

              {/* Main Grid */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-[calc(100vh-280px)]">
                
                {/* Left: Live Incident Feed */}
                <div className="bg-slate-900/50 border border-slate-800 rounded-lg overflow-hidden flex flex-col">
                  <div className="bg-slate-900 border-b border-slate-800 p-4 flex justify-between items-center">
                    <h2 className="text-lg font-bold flex items-center gap-2">
                      <Activity className="w-5 h-5 text-red-500" />
                      Incoming Field Reports
                    </h2>
                    <span className="text-xs bg-red-500/10 text-red-500 px-2 py-1 rounded border border-red-500/20 animate-pulse">
                      {incidents.length} Events
                    </span>
                  </div>
                  
                  <div className="flex-1 overflow-auto p-4 custom-scrollbar">
                    {incidents.length === 0 ? (
                      <div className="text-center text-slate-500 py-12 flex flex-col items-center">
                        <ShieldAlert className="w-12 h-12 mb-4 opacity-20" />
                        No incidents reported yet.
                      </div>
                    ) : (
                      incidents.map(incident => (
                        <IncidentRow 
                          key={incident.id} 
                          incident={incident} 
                          onUpdateStatus={updateStatus} // Pass the dispatch function
                        />
                      ))
                    )}
                  </div>
                </div>

                {/* Right: Tactical Map */}
                <div className="bg-slate-900/50 border border-slate-800 rounded-lg overflow-hidden flex flex-col">
                   <div className="flex-1 relative">
                      <MapView incidents={incidents} />
                   </div>
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