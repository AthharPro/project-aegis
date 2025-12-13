import React, { useState, useEffect } from 'react';
import { 
  Radio, 
  Users, 
  AlertTriangle, 
  Activity, 
  MapPin, 
  Clock,
  Settings,
  LayoutDashboard,
  MapPinned,
  Wifi,
  WifiOff
} from 'lucide-react';

// ============================================================================
// TYPE DEFINITIONS
// ============================================================================

interface Victim {
  id: string;
  full_name: string;
  injury_status: 'Critical' | 'Stable' | 'Deceased';
  gps_lat: number;
  gps_long: number;
  created_at: string;
  officer_id: string;
}

// ============================================================================
// MOCK DATA & HOOK
// ============================================================================

const MOCK_VICTIMS: Victim[] = [
  {
    id: '1',
    full_name: 'John Anderson',
    injury_status: 'Critical',
    gps_lat: 6.9271,
    gps_long: 79.8612,
    created_at: new Date(Date.now() - 120000).toISOString(),
    officer_id: 'off-001'
  },
  {
    id: '2',
    full_name: 'Sarah Mitchell',
    injury_status: 'Stable',
    gps_lat: 6.9155,
    gps_long: 79.8750,
    created_at: new Date(Date.now() - 300000).toISOString(),
    officer_id: 'off-002'
  },
  {
    id: '3',
    full_name: 'Michael Chen',
    injury_status: 'Critical',
    gps_lat: 6.9350,
    gps_long: 79.8500,
    created_at: new Date(Date.now() - 450000).toISOString(),
    officer_id: 'off-003'
  },
  {
    id: '4',
    full_name: 'Emma Rodriguez',
    injury_status: 'Stable',
    gps_lat: 6.9100,
    gps_long: 79.8650,
    created_at: new Date(Date.now() - 600000).toISOString(),
    officer_id: 'off-001'
  },
  {
    id: '5',
    full_name: 'David Thompson',
    injury_status: 'Deceased',
    gps_lat: 6.9200,
    gps_long: 79.8550,
    created_at: new Date(Date.now() - 900000).toISOString(),
    officer_id: 'off-004'
  }
];

// Custom hook to simulate Supabase connection with realtime updates
const useVictims = () => {
  const [victims, setVictims] = useState<Victim[]>([]);
  const [isConnected, setIsConnected] = useState(true);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Simulate initial data fetch
    setTimeout(() => {
      setVictims(MOCK_VICTIMS);
      setIsLoading(false);
    }, 800);

    // Simulate realtime updates every 15 seconds
    const interval = setInterval(() => {
      const newVictim: Victim = {
        id: `mock-${Date.now()}`,
        full_name: [
          'Alex Parker',
          'Maria Santos',
          'James Wilson',
          'Lisa Brown',
          'Robert Taylor'
        ][Math.floor(Math.random() * 5)],
        injury_status: ['Critical', 'Stable', 'Deceased'][Math.floor(Math.random() * 3)] as any,
        gps_lat: 6.9271 + (Math.random() - 0.5) * 0.05,
        gps_long: 79.8612 + (Math.random() - 0.5) * 0.05,
        created_at: new Date().toISOString(),
        officer_id: `off-00${Math.floor(Math.random() * 5) + 1}`
      };

      setVictims(prev => [newVictim, ...prev]);
    }, 15000);

    // Simulate connection status changes
    const connectionInterval = setInterval(() => {
      setIsConnected(prev => Math.random() > 0.1 ? true : prev);
    }, 5000);

    return () => {
      clearInterval(interval);
      clearInterval(connectionInterval);
    };
  }, []);

  return { victims, isConnected, isLoading };
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

const getStatusColor = (status: Victim['injury_status']) => {
  switch (status) {
    case 'Critical':
      return 'bg-red-500/20 text-red-400 border-red-500/50';
    case 'Stable':
      return 'bg-emerald-500/20 text-emerald-400 border-emerald-500/50';
    case 'Deceased':
      return 'bg-slate-500/20 text-slate-400 border-slate-500/50';
    default:
      return 'bg-amber-500/20 text-amber-400 border-amber-500/50';
  }
};

const getStatusDot = (status: Victim['injury_status']) => {
  switch (status) {
    case 'Critical':
      return 'bg-red-500';
    case 'Stable':
      return 'bg-emerald-500';
    case 'Deceased':
      return 'bg-slate-500';
    default:
      return 'bg-amber-500';
  }
};

const formatTimestamp = (timestamp: string) => {
  const now = new Date();
  const past = new Date(timestamp);
  const diffMs = now.getTime() - past.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  
  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins}m ago`;
  const diffHours = Math.floor(diffMins / 60);
  if (diffHours < 24) return `${diffHours}h ago`;
  return `${Math.floor(diffHours / 24)}d ago`;
};

// ============================================================================
// COMPONENTS
// ============================================================================

const StatCard: React.FC<{
  icon: React.ReactNode;
  label: string;
  value: number | string;
  trend?: string;
  color: string;
}> = ({ icon, label, value, trend, color }) => (
  <div className="bg-slate-800/50 border border-slate-700/50 rounded-lg p-4 backdrop-blur-sm">
    <div className="flex items-start justify-between">
      <div className="flex-1">
        <div className="flex items-center gap-2 text-slate-400 text-sm mb-2">
          {icon}
          <span className="uppercase tracking-wider font-medium">{label}</span>
        </div>
        <div className={`text-3xl font-bold ${color} mb-1`}>{value}</div>
        {trend && (
          <div className="text-xs text-slate-500 font-mono">{trend}</div>
        )}
      </div>
    </div>
  </div>
);

const VictimRow: React.FC<{ victim: Victim }> = ({ victim }) => (
  <div className={`border rounded-lg p-3 ${getStatusColor(victim.injury_status)} transition-all hover:border-slate-500`}>
    <div className="flex items-start justify-between gap-3">
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1">
          <div className={`w-2 h-2 rounded-full ${getStatusDot(victim.injury_status)} animate-pulse`} />
          <span className="font-semibold text-slate-100 truncate">{victim.full_name}</span>
        </div>
        <div className="flex items-center gap-3 text-xs text-slate-400">
          <div className="flex items-center gap-1">
            <MapPin className="w-3 h-3" />
            <span className="font-mono">
              {victim.gps_lat.toFixed(4)}, {victim.gps_long.toFixed(4)}
            </span>
          </div>
          <div className="flex items-center gap-1">
            <Clock className="w-3 h-3" />
            <span>{formatTimestamp(victim.created_at)}</span>
          </div>
        </div>
      </div>
      <div className="flex-shrink-0">
        <span className={`px-2 py-1 rounded text-xs font-bold ${getStatusColor(victim.injury_status)}`}>
          {victim.injury_status.toUpperCase()}
        </span>
      </div>
    </div>
  </div>
);

const MapView: React.FC<{ victims: Victim[] }> = ({ victims }) => {
  const centerLat = victims.length > 0 
    ? victims.reduce((sum, v) => sum + v.gps_lat, 0) / victims.length 
    : 6.9271;
  const centerLng = victims.length > 0 
    ? victims.reduce((sum, v) => sum + v.gps_long, 0) / victims.length 
    : 79.8612;

  return (
    <div className="relative w-full h-full bg-slate-900 rounded-lg overflow-hidden border border-slate-700/50">
      {/* Map Header */}
      <div className="absolute top-0 left-0 right-0 z-10 bg-slate-900/90 backdrop-blur-sm border-b border-slate-700/50 p-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 text-slate-300">
            <MapPinned className="w-4 h-4" />
            <span className="text-sm font-semibold uppercase tracking-wide">Tactical Map</span>
          </div>
          <div className="text-xs text-slate-500 font-mono">
            Center: {centerLat.toFixed(4)}, {centerLng.toFixed(4)}
          </div>
        </div>
      </div>

      {/* Simplified Map Visualization */}
      <div className="absolute inset-0 pt-14">
        <svg className="w-full h-full" viewBox="0 0 800 600">
          {/* Grid */}
          <defs>
            <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
              <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#1e293b" strokeWidth="0.5"/>
            </pattern>
          </defs>
          <rect width="800" height="600" fill="url(#grid)" />
          
          {/* Victim Markers */}
          {victims.map((victim, idx) => {
            const x = 400 + (victim.gps_long - centerLng) * 8000;
            const y = 300 - (victim.gps_lat - centerLat) * 8000;
            const color = victim.injury_status === 'Critical' ? '#ef4444' 
              : victim.injury_status === 'Stable' ? '#10b981' 
              : '#64748b';
            
            return (
              <g key={victim.id}>
                {/* Ping Animation */}
                <circle cx={x} cy={y} r="20" fill={color} opacity="0.3">
                  <animate attributeName="r" from="10" to="30" dur="2s" repeatCount="indefinite" />
                  <animate attributeName="opacity" from="0.5" to="0" dur="2s" repeatCount="indefinite" />
                </circle>
                {/* Marker */}
                <circle cx={x} cy={y} r="6" fill={color} stroke="#0f172a" strokeWidth="2" />
                <text x={x} y={y - 12} fill="#e2e8f0" fontSize="10" textAnchor="middle" className="font-mono">
                  {idx + 1}
                </text>
              </g>
            );
          })}
        </svg>
      </div>

      {/* Legend */}
      <div className="absolute bottom-3 right-3 bg-slate-900/90 backdrop-blur-sm border border-slate-700/50 rounded p-2">
        <div className="space-y-1">
          {[
            { label: 'Critical', color: 'bg-red-500' },
            { label: 'Stable', color: 'bg-emerald-500' },
            { label: 'Deceased', color: 'bg-slate-500' }
          ].map(({ label, color }) => (
            <div key={label} className="flex items-center gap-2 text-xs">
              <div className={`w-3 h-3 rounded-full ${color}`} />
              <span className="text-slate-400">{label}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// ============================================================================
// MAIN DASHBOARD
// ============================================================================

const HQCommandCenter: React.FC = () => {
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
      {/* Sidebar */}
      <div className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col">
        {/* Logo */}
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

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-2">
          {[
            { id: 'dashboard', icon: LayoutDashboard, label: 'Dashboard' },
            { id: 'map', icon: MapPinned, label: 'Map View' },
            { id: 'officers', icon: Users, label: 'Officers' },
            { id: 'settings', icon: Settings, label: 'Settings' }
          ].map(item => (
            <button
              key={item.id}
              onClick={() => setActiveView(item.id)}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
                activeView === item.id
                  ? 'bg-red-600 text-white'
                  : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
              }`}
            >
              <item.icon className="w-5 h-5" />
              <span className="font-medium">{item.label}</span>
            </button>
          ))}
        </nav>

        {/* Footer */}
        <div className="p-4 border-t border-slate-800">
          <div className="text-xs text-slate-500 space-y-1">
            <div className="font-mono">v2.4.1</div>
            <div>© 2025 Army HQ</div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Bar */}
        <div className="bg-slate-900 border-b border-slate-800 px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold">Rescue Operations Center</h1>
              <p className="text-sm text-slate-500">Real-time victim tracking and coordination</p>
            </div>
            <div className="flex items-center gap-4">
              {/* Live Indicator */}
              <div className="flex items-center gap-2 bg-slate-800 px-4 py-2 rounded-lg">
                <Activity className="w-4 h-4 text-red-500 animate-pulse" />
                <span className="text-sm font-semibold text-red-500">LIVE</span>
              </div>
              {/* Connection Status */}
              <div className={`flex items-center gap-2 px-4 py-2 rounded-lg ${
                isConnected ? 'bg-emerald-500/20 text-emerald-400' : 'bg-red-500/20 text-red-400'
              }`}>
                {isConnected ? <Wifi className="w-4 h-4" /> : <WifiOff className="w-4 h-4" />}
                <span className="text-sm font-semibold">
                  {isConnected ? 'CONNECTED' : 'OFFLINE'}
                </span>
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
                <StatCard
                  icon={<Users className="w-4 h-4" />}
                  label="Total Victims"
                  value={stats.total}
                  trend="All time"
                  color="text-slate-100"
                />
                <StatCard
                  icon={<AlertTriangle className="w-4 h-4" />}
                  label="Critical"
                  value={stats.critical}
                  trend="Requires immediate attention"
                  color="text-red-500"
                />
                <StatCard
                  icon={<Activity className="w-4 h-4" />}
                  label="Stable"
                  value={stats.stable}
                  trend="Condition monitored"
                  color="text-emerald-500"
                />
                <StatCard
                  icon={<Clock className="w-4 h-4" />}
                  label="Recent Sync"
                  value={stats.recentlyAdded}
                  trend="Last 10 minutes"
                  color="text-amber-500"
                />
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
                    <p className="text-xs text-slate-500 mt-1">
                      Most recent victims appear first
                    </p>
                  </div>
                  <div className="flex-1 overflow-auto p-4 space-y-2">
                    {victims.length === 0 ? (
                      <div className="text-center text-slate-500 py-12">
                        No victims reported yet
                      </div>
                    ) : (
                      victims.map(victim => (
                        <VictimRow key={victim.id} victim={victim} />
                      ))
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

export default HQCommandCenter;