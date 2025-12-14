import React, { useState, useMemo, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import {
    ShieldAlert,
    Users,
    Activity,
    Filter,
    Crosshair,
    Clock,
    Map as MapIcon
} from 'lucide-react';
import { useIncidents } from '../hooks/UseVictim';
import { getSeverityConfig, formatVictimCount } from '../utils/helper';
import { formatDistanceToNow } from 'date-fns';
import { format } from 'date-fns';
import { IncidentModal } from '../components/IncidentModel'; // <--- Import Modal
import type { Incident } from '../types';

// --- 1. Map Controller (Auto-Focus Logic) ---
const MapController = ({ center }: { center: [number, number] }) => {
    const map = useMap();
    useEffect(() => {
        map.flyTo(center, map.getZoom());
    }, [center, map]);
    return null;
};

// --- 2. Custom Icons ---
const createIcon = (color: string, pulse: boolean = false) => new L.DivIcon({
    className: 'custom-icon',
    html: `<div style="
    background-color: ${color}; 
    width: 14px; 
    height: 14px; 
    border-radius: 50%; 
    border: 2px solid white; 
    box-shadow: 0 0 10px ${color};
    ${pulse ? 'animation: pulse 1.5s infinite;' : ''}
  "></div>`,
    iconSize: [14, 14],
    iconAnchor: [7, 7],
});

const getIconForSeverity = (severity: number) => {
    if (severity >= 5) return createIcon('#ef4444', true);  // CRITICAL (Red + Pulse)
    if (severity === 4) return createIcon('#f97316');       // HIGH (Orange)
    if (severity === 3) return createIcon('#eab308');       // MODERATE (Yellow)
    if (severity === 2) return createIcon('#8b5cf6');       // MINOR (Violet)
    return createIcon('#10b981');                           // LOW (Emerald/Green)
};

// --- 3. Main Mission Command Component ---
const MissionCommand: React.FC = () => {
    const { incidents, isLoading, updateStatus } = useIncidents(); // Get updateStatus
    const [filterSeverity, setFilterSeverity] = useState<string>('all');
    const [currentTime, setCurrentTime] = useState(new Date());

    // Modal State
    const [selectedIncident, setSelectedIncident] = useState<Incident | null>(null);

    // Default Map Center (Colombo)
    const [mapCenter, setMapCenter] = useState<[number, number]>([7.8731, 80.7718]);

    // Live Clock
    useEffect(() => {
        const timer = setInterval(() => setCurrentTime(new Date()), 1000);
        return () => clearInterval(timer);
    }, []);

    // Stats Calculation
    const stats = useMemo(() => {
        const active = incidents.length;
        const critical = incidents.filter(i => i.severity >= 4).length;
        const victims = incidents.reduce((acc, curr) => acc + curr.victim_count, 0);
        return { active, critical, victims };
    }, [incidents]);

    // Filtering Logic
    const filteredIncidents = useMemo(() => {
        if (filterSeverity === 'all') return incidents;
        if (filterSeverity === 'critical') return incidents.filter(i => i.severity >= 4);
        if (filterSeverity === 'moderate') return incidents.filter(i => i.severity === 3 || i.severity === 2);
        return incidents;
    }, [incidents, filterSeverity]);

    // Focus Action
    const handleFocusCritical = () => {
        const critical = incidents.find(i => i.severity >= 5);
        if (critical) {
            setMapCenter([critical.latitude, critical.longitude]);
        }
    };

    // Resolve Logic (Passed to Modal)
    const handleResolve = (id: string) => {
        updateStatus(id, 'RESOLVED');
        setSelectedIncident(null);
        setTimeout(() => {
            updateStatus(id, 'COMPLETED');
        }, 2000);
    };

    return (
        <div className="relative w-screen h-screen bg-slate-950 overflow-hidden text-slate-100 font-sans">

            {/* --- LAYER 1: MAP --- */}
            <div className="absolute inset-0 z-0">
                <MapContainer
                    center={mapCenter}
                    zoom={8}
                    zoomControl={false}
                    style={{ height: '100%', width: '100%' }}
                    className="bg-slate-950"
                >
                    <TileLayer
                        attribution='&copy; <a href="https://carto.com/">CARTO</a>'
                        url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
                    />
                    <MapController center={mapCenter} />

                    {filteredIncidents.map((incident) => {
                        const config = getSeverityConfig(incident.severity);
                        const bgColorClass = config.color.replace('text-', 'bg-').replace('-400', '-500');

                        return (
                            <Marker
                                key={incident.id}
                                position={[incident.latitude, incident.longitude]}
                                icon={getIconForSeverity(incident.severity)}
                                // Click Handler to Open Modal
                                eventHandlers={{
                                    click: () => setSelectedIncident(incident),
                                }}
                            >
                                <Popup
                                    className="mission-popup"
                                    closeButton={false}
                                >
                                    <div className="bg-slate-900 text-slate-100 p-3 rounded shadow-xl border border-slate-700 min-w-[200px]">
                                        <div className="flex justify-between items-center mb-2">
                                            <span className="font-bold text-sm">{incident.incident_type}</span>
                                            <span className={`text-[10px] px-2 py-0.5 rounded font-bold text-white ${bgColorClass}`}>
                                                {config.label}
                                            </span>
                                        </div>
                                        <div className="text-xs text-slate-400 mb-2">
                                            {incident.profiles?.full_name || 'Unknown Officer'}
                                        </div>
                                        <div className="text-xs font-mono text-slate-500 mb-1">
                                            Reported {formatDistanceToNow(new Date(incident.incident_time), { addSuffix: true })}
                                        </div>
                                        <div className="text-[9px] text-center text-blue-400 uppercase font-bold tracking-wider border-t border-slate-700 pt-1">
                                            Click for Details
                                        </div>
                                    </div>
                                </Popup>
                            </Marker>
                        );
                    })}
                </MapContainer>
            </div>

            {/* --- LAYER 2: HUD OVERLAYS --- */}

            {/* Top Left: Title */}
            <div className="absolute top-6 left-6 z-10 flex flex-col gap-2 pointer-events-none">
                <div className="bg-slate-900/90 backdrop-blur-md border border-slate-700 p-4 rounded-lg shadow-2xl flex items-center gap-4">
                    <div className="bg-blue-600 p-2 rounded-lg text-white">
                        <MapIcon size={24} />
                    </div>
                    <div>
                        <h1 className="text-xl font-bold tracking-tight text-white leading-none">FULL MAP</h1>
                        <span className="text-xs text-blue-400 font-mono tracking-wider uppercase">Live Tactical Feed</span>
                    </div>
                </div>
            </div>

            {/* Top Right: Clock */}
            <div className="absolute top-6 right-6 z-10 pointer-events-none">
                <div className="bg-slate-900/90 backdrop-blur-md border border-slate-700 px-5 py-3 rounded-lg shadow-2xl flex items-center gap-4">
                    <div className="text-right">
                        <div className="text-2xl font-mono font-bold text-slate-100">{format(currentTime, 'HH:mm:ss')}</div>
                        <div className="text-xs text-slate-500 font-bold uppercase">{format(currentTime, 'EEEE, MMM do')}</div>
                    </div>
                    <Clock className="text-slate-600" size={32} />
                </div>
            </div>

            {/* Bottom Left: Stats */}
            <div className="absolute bottom-6 left-6 z-10 flex gap-4 pointer-events-auto">

                {/* Active */}
                <div className="bg-slate-900/90 backdrop-blur-md border border-slate-700 p-4 rounded-lg shadow-lg w-40 hover:border-blue-500 transition-colors cursor-default">
                    <div className="flex items-center gap-2 text-slate-400 mb-1">
                        <Activity size={16} />
                        <span className="text-xs font-bold uppercase">Active</span>
                    </div>
                    <div className="text-3xl font-bold text-white">{isLoading ? '-' : stats.active}</div>
                </div>

                {/* Critical */}
                <div className="bg-slate-900/90 backdrop-blur-md border border-slate-700 p-4 rounded-lg shadow-lg w-40 hover:border-red-500 transition-colors cursor-default">
                    <div className="flex items-center gap-2 text-red-400 mb-1">
                        <ShieldAlert size={16} />
                        <span className="text-xs font-bold uppercase">Critical</span>
                    </div>
                    <div className="text-3xl font-bold text-red-500">{isLoading ? '-' : stats.critical}</div>
                    {stats.critical > 0 && <div className="text-[10px] text-red-400 animate-pulse mt-1">ATTENTION REQUIRED</div>}
                </div>

                {/* Victims */}
                <div className="bg-slate-900/90 backdrop-blur-md border border-slate-700 p-4 rounded-lg shadow-lg w-40 hover:border-orange-500 transition-colors cursor-default">
                    <div className="flex items-center gap-2 text-orange-400 mb-1">
                        <Users size={16} />
                        <span className="text-xs font-bold uppercase">Victims</span>
                    </div>
                    <div className="text-3xl font-bold text-white">{isLoading ? '-' : formatVictimCount(stats.victims)}</div>
                </div>
            </div>

            {/* Bottom Right: Controls */}
            <div className="absolute bottom-6 right-6 z-10 flex flex-col gap-3 pointer-events-auto">
                <button
                    onClick={handleFocusCritical}
                    className="bg-slate-800 hover:bg-red-600 hover:text-white text-slate-300 p-3 rounded-full shadow-lg border border-slate-600 transition-all group relative"
                    title="Focus Critical"
                >
                    <Crosshair size={20} />
                    <span className="absolute right-full mr-3 top-1/2 -translate-y-1/2 bg-slate-900 text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap border border-slate-700 pointer-events-none">
                        Find Critical
                    </span>
                </button>

                <div className="bg-slate-900/90 backdrop-blur-md border border-slate-700 rounded-lg shadow-lg p-2 flex flex-col gap-2">
                    <div className="text-[10px] text-slate-500 font-bold uppercase text-center mb-1">Filters</div>

                    <button
                        onClick={() => setFilterSeverity('all')}
                        className={`p-2 rounded transition-colors ${filterSeverity === 'all' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:bg-slate-800'}`}
                        title="Show All"
                    >
                        <Filter size={18} />
                    </button>

                    <button
                        onClick={() => setFilterSeverity('critical')}
                        className={`p-2 rounded transition-colors ${filterSeverity === 'critical' ? 'bg-red-600 text-white' : 'text-slate-400 hover:bg-slate-800'}`}
                        title="Show Critical Only"
                    >
                        <ShieldAlert size={18} />
                    </button>
                </div>
            </div>

            {/* --- LAYER 3: MODAL --- */}
            <IncidentModal
                incident={selectedIncident}
                onClose={() => setSelectedIncident(null)}
                onResolve={handleResolve}
            />

        </div>
    );
};

export default MissionCommand;