import type { Victim } from '../types';

export const getStatusColor = (status: Victim['injury_status']) => {
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

export const getStatusDot = (status: Victim['injury_status']) => {
  switch (status) {
    case 'Critical': return 'bg-red-500';
    case 'Stable': return 'bg-emerald-500';
    case 'Deceased': return 'bg-slate-500';
    default: return 'bg-amber-500';
  }
};

export const formatTimestamp = (timestamp: string) => {
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