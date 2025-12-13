import { formatDistanceToNow } from 'date-fns';

// 1. SEVERITY (Input - The Situation)
export const getSeverityConfig = (severity: number) => {
  // Assuming scale 1-5
  if (severity >= 4) return { label: 'CRITICAL', color: 'text-red-500', bg: 'bg-red-500/20', border: 'border-red-500' };
  if (severity === 3) return { label: 'HIGH', color: 'text-orange-500', bg: 'bg-orange-500/20', border: 'border-orange-500' };
  if (severity === 2) return { label: 'MODERATE', color: 'text-yellow-500', bg: 'bg-yellow-500/20', border: 'border-yellow-500' };
  return { label: 'LOW', color: 'text-blue-500', bg: 'bg-blue-500/20', border: 'border-blue-500' };
};

// 2. STATUS (Output - The HQ Action)
export const getStatusConfig = (status: string) => {
  switch (status) {
    case 'PENDING': return { label: 'PENDING', color: 'text-red-400', bg: 'bg-red-600/10 border border-red-600/30' };
    case 'RESOLVED': return { label: 'RESOLVED', color: 'text-amber-400', bg: 'bg-amber-400/10 border border-amber-400/30' };
    case 'COMPLETED': return { label: 'COMPLETED', color: 'text-emerald-400', bg: 'bg-emerald-500/10 border border-emerald-500/30' };
    default: return { label: status, color: 'text-slate-400', bg: 'bg-slate-800' };
  }
};

export const formatTimestamp = (timestamp: string) => {
  return formatDistanceToNow(new Date(timestamp), { addSuffix: true });
};