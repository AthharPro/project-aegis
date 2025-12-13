import React from 'react';
import { MapPin, Clock, Radio } from 'lucide-react';
import type { Incident, IncidentStatus } from '../types';
import { getSeverityConfig, getStatusConfig, formatTimestamp } from '../utils/helper';

interface Props {
  incident: Incident;
  onUpdateStatus?: (id: string, status: IncidentStatus) => void; // Optional callback
}

export const IncidentRow: React.FC<Props> = ({ incident, onUpdateStatus }) => {
  const severity = getSeverityConfig(incident.severity);
  const status = getStatusConfig(incident.status);

  // Helper to handle Dropdown change
  const handleStatusChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    if (onUpdateStatus) {
      onUpdateStatus(incident.id, e.target.value as IncidentStatus);
    }
  };

  return (
    <div className={`
      relative overflow-hidden rounded-lg border border-slate-800 bg-slate-900/50 mb-3
      transition-all hover:border-slate-600 hover:bg-slate-900
      ${incident.status === 'PENDING' ? 'border-l-4 border-l-red-500' : ''} 
    `}>
      <div className="flex flex-col md:flex-row items-stretch">
        
        {/* LEFT: The Situation (Read-Only) */}
        <div className="flex-1 p-4">
          <div className="flex justify-between items-start mb-2">
            <div>
               <h3 className="font-bold text-lg text-slate-100 flex items-center gap-2">
                  {incident.incident_type}
                  <span className={`text-[10px] px-2 py-0.5 rounded border ${severity.color} ${severity.border} ${severity.bg}`}>
                    LVL {incident.severity}
                  </span>
               </h3>
               <p className="text-xs text-slate-500 mt-1">
                 Reported by <span className="text-slate-300">{incident.profiles?.full_name || 'Unknown Officer'}</span>
               </p>
            </div>
            
            {/* Victim Counter */}
            {incident.victim_count > 0 && (
              <div className="text-center bg-slate-800 px-3 py-1 rounded border border-slate-700">
                <div className="text-lg font-bold text-white leading-none">{incident.victim_count}</div>
                <div className="text-[9px] text-slate-500 uppercase">Victims</div>
              </div>
            )}
          </div>

          <div className="flex gap-4 text-xs text-slate-400 mt-3 font-mono">
            <span className="flex items-center gap-1">
              <MapPin size={12} /> {incident.latitude.toFixed(4)}, {incident.longitude.toFixed(4)}
            </span>
            <span className="flex items-center gap-1">
              <Clock size={12} /> {formatTimestamp(incident.incident_time)}
            </span>
          </div>
        </div>

        {/* RIGHT: The HQ Response (Interactive) */}
        <div className="w-full md:w-48 bg-slate-950/50 border-t md:border-t-0 md:border-l border-slate-800 p-4 flex flex-col justify-center gap-2">
           <div className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-1 flex items-center gap-1">
             <Radio size={10} /> HQ Status
           </div>
           
           {/* If we passed an update function, show a dropdown. Otherwise just show a badge */}
           {onUpdateStatus ? (
             <select 
               value={incident.status}
               onChange={handleStatusChange}
               className={`
                 w-full text-xs font-bold py-2 px-3 rounded cursor-pointer outline-none appearance-none text-center
                 ${status.bg} ${status.color}
               `}
             >
               <option value="PENDING" className="bg-slate-900 text-red-500">PENDING</option>
               <option value="DISPATCHED" className="bg-slate-900 text-amber-500">DISPATCHED</option>
               <option value="ON_SITE" className="bg-slate-900 text-blue-500">ON SITE</option>
               <option value="RESOLVED" className="bg-slate-900 text-emerald-500">RESOLVED</option>
             </select>
           ) : (
             <div className={`text-center text-xs font-bold py-1 px-2 rounded ${status.bg} ${status.color}`}>
               {status.label}
             </div>
           )}
        </div>

      </div>
    </div>
  );
};