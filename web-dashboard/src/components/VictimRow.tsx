import React from 'react';
import { MapPin, Clock } from 'lucide-react';
import type { Victim } from '../types';
import { getStatusColor, getStatusDot, formatTimestamp } from '../utils/helper';

export const VictimRow: React.FC<{ victim: Victim }> = ({ victim }) => (
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