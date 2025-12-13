import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import type { Incident } from '../types';
import { formatDistanceToNow } from 'date-fns';
import { formatVictimCount } from '../utils/helper';
//import { getSeverityConfig } from '../utils/helper';

// --- Icon Factory ---
const createIcon = (color: string) => new L.DivIcon({
    className: 'custom-icon',
    html: `<div style="background-color: ${color}; width: 14px; height: 14px; border-radius: 50%; border: 2px solid white; box-shadow: 0 0 10px ${color};"></div>`,
    iconSize: [14, 14],
    iconAnchor: [7, 7], // Center the icon
});

// Map Severity Levels to Hex Colors for Leaflet
const getIconForSeverity = (severity: number) => {
    if (severity >= 4) return createIcon('#ef4444'); // Red (Critical)
    if (severity === 3) return createIcon('#f97316'); // Orange (High)
    if (severity === 2) return createIcon('#eab308'); // Yellow (Moderate)
    return createIcon('#10b981'); // Emerald (Low)
};

export const MapView: React.FC<{ incidents: Incident[] }> = ({ incidents }) => {
    // Default center (Colombo, Sri Lanka)
    const defaultCenter: [number, number] = [6.9271, 79.8612];

    // Calculate center based on first incident if available
    const center: [number, number] = incidents.length > 0
        ? [incidents[0].latitude, incidents[0].longitude]
        : defaultCenter;

    return (
        <div className="h-full w-full rounded-lg overflow-hidden border border-slate-700 relative z-0">
            <MapContainer
                center={center}
                zoom={13}
                scrollWheelZoom={true}
                style={{ height: '100%', width: '100%' }}
            >
                {/* Dark Matter Map Tiles */}
                <TileLayer
                    url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
                />

                {/* Render Markers */}
                {incidents.map((incident) => {
                    //const config = getSeverityConfig(incident.severity);

                    return (
                        <Marker
                            key={incident.id}
                            position={[incident.latitude, incident.longitude]}
                            icon={getIconForSeverity(incident.severity)}
                        >
                            <Popup className="custom-popup">
                                <div className="text-slate-900 min-w-[150px]">
                                    {/* Header */}
                                    <div className="flex justify-between items-start mb-1">
                                        <strong className="block text-sm font-bold uppercase">{incident.incident_type}</strong>
                                        <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded text-white ${incident.severity >= 4 ? 'bg-red-500' :
                                                incident.severity === 3 ? 'bg-orange-500' :
                                                    incident.severity === 2 ? 'bg-yellow-500' : 'bg-emerald-500'
                                            }`}>
                                            LVL {incident.severity}
                                        </span>
                                    </div>

                                    {/* Details */}
                                    <div className="text-xs text-slate-600 mb-2">
                                        {incident.victim_count > 0 ? (
                                            <span className="font-semibold text-slate-800">{formatVictimCount(incident.victim_count)} Victims Reported</span>
                                        ) : (
                                            <span>No victims reported</span>
                                        )}
                                    </div>

                                    {/* Footer */}
                                    <div className="border-t border-slate-200 pt-1 mt-1 flex justify-between items-center text-[10px] text-slate-500">
                                        <span>{incident.profiles?.full_name || 'Unknown Officer'}</span>
                                        <span>{formatDistanceToNow(new Date(incident.incident_time), { addSuffix: true })}</span>
                                    </div>
                                </div>
                            </Popup>
                        </Marker>
                    );
                })}
            </MapContainer>
        </div>
    );
};