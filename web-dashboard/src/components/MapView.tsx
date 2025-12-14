import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import type { Incident } from '../types';
import { formatDistanceToNow } from 'date-fns';
import { formatVictimCount } from '../utils/helper';
import { getSeverityConfig } from '../utils/helper';

// --- Icon Factory ---
const createIcon = (color: string) => new L.DivIcon({
    className: 'custom-icon',
    html: `<div style="background-color: ${color}; width: 14px; height: 14px; border-radius: 50%; border: 2px solid white; box-shadow: 0 0 10px ${color};"></div>`,
    iconSize: [14, 14],
    iconAnchor: [7, 7], // Center the icon
});

// Map Severity Levels to Hex Colors for Leaflet
const getIconForSeverity = (severity: number) => {
    if (severity >= 5) return createIcon('#ef4444');
    if (severity === 4) return createIcon('#f97316');
    if (severity === 3) return createIcon('#eab308');
    if (severity === 2) return createIcon('#8b5cf6');
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
                {/* Render Markers */}
                {incidents.map((incident) => {
                    // 1. Get the full config object
                    const config = getSeverityConfig(incident.severity);

                    // Helper to map Tailwind color names to background classes
                    // Example: 'text-red-500' -> 'bg-red-500'
                    const bgColorClass = config.color.replace('text-', 'bg-').replace('-400', '-500');


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

                                        {/* 2. RENDER THE WORD LABEL and use the derived class */}
                                        <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded text-white ${bgColorClass}`}>
                                            {config.label} {/* <-- SHOWS THE WORD (CRITICAL, HIGH, etc.) */}
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
                                        <span>
                                            Reported {formatDistanceToNow(new Date(incident.incident_time), { addSuffix: true })}
                                        </span>
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