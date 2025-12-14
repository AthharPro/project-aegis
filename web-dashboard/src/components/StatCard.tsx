import React from 'react';

interface StatCardProps {
  icon: React.ReactNode;
  label: string;
  value: number | string;
  trend?: string;
  color: string;
}

export const StatCard: React.FC<StatCardProps> = ({ icon, label, value, trend, color }) => (
  <div className="bg-slate-800/50 border border-slate-700/50 rounded-lg p-4 backdrop-blur-sm transition-all hover:bg-slate-800/70">
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