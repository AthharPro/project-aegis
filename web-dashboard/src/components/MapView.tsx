import React from 'react';
import { MapPinned } from 'lucide-react';
import type { Victim } from '../types';

export const MapView: React.FC<{ victims: Victim[] }> = ({ victims }) => {
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

      {/* SVG Map Visualization */}
      <div className="absolute inset-0 pt-14">
        <svg className="w-full h-full" viewBox="0 0 800 600">
          <defs>
            <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
              <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#1e293b" strokeWidth="0.5"/>
            </pattern>
          </defs>
          <rect width="800" height="600" fill="url(#grid)" />
          
          {victims.map((victim, idx) => {
            const x = 400 + (victim.gps_long - centerLng) * 8000;
            const y = 300 - (victim.gps_lat - centerLat) * 8000;
            const color = victim.injury_status === 'Critical' ? '#ef4444' 
              : victim.injury_status === 'Stable' ? '#10b981' 
              : '#64748b';
            
            return (
              <g key={victim.id}>
                <circle cx={x} cy={y} r="20" fill={color} opacity="0.3">
                  <animate attributeName="r" from="10" to="30" dur="2s" repeatCount="indefinite" />
                  <animate attributeName="opacity" from="0.5" to="0" dur="2s" repeatCount="indefinite" />
                </circle>
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
          {[{ label: 'Critical', color: 'bg-red-500' }, { label: 'Stable', color: 'bg-emerald-500' }, { label: 'Deceased', color: 'bg-slate-500' }]
            .map(({ label, color }) => (
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