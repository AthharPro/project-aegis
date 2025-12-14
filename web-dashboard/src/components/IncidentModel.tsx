import React, { useState, useEffect } from 'react';
import { User, Clock, MapPin, AlertCircle, Camera, XCircle, Check } from 'lucide-react';
import { getSeverityConfig, getStatusConfig } from '../utils/helper'; // Adjust path if needed
import type { Incident } from '../types';

interface IncidentModalProps {
    incident: Incident | null;
    onClose: () => void;
    onResolve: (id: string) => void;
}

export const IncidentModal: React.FC<IncidentModalProps> = ({ incident, onClose, onResolve }) => {
    const [imageError, setImageError] = useState(false);

    // Reset error state when a new incident opens
    useEffect(() => {
        if (incident) setImageError(false);
    }, [incident]);

    // If no incident is selected, render nothing
    if (!incident) return null;

    return (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
            <div className="bg-slate-900 border border-slate-700 w-full max-w-2xl rounded-lg shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">

                {/* Modal Header */}
                <div className="p-4 border-b border-slate-800 flex justify-between items-center bg-slate-950">
                    <div className="flex items-center gap-3">
                        <span className="text-lg font-bold text-white uppercase tracking-wide">
                            INCIDENT #{incident.id.slice(0, 8)}
                        </span>
                        {/* Status Badge */}
                        <span className={`px-2 py-0.5 rounded text-[10px] font-bold border ${getStatusConfig(incident.status).color} ${getStatusConfig(incident.status).bg} border-opacity-50`}>
                            {incident.status}
                        </span>
                    </div>
                    <button onClick={onClose} className="text-slate-500 hover:text-white transition-colors">
                        <XCircle size={24} />
                    </button>
                </div>

                {/* Modal Body (Scrollable) */}
                <div className="flex-1 overflow-y-auto p-6 space-y-6">

                    {/* 1. Image Section */}
                    <div className="w-full h-full bg-slate-950 rounded-lg border border-slate-800 flex items-center justify-center overflow-hidden relative group">
                        {incident.image_url && !imageError ? (
                            <img
                                src={incident.image_url}
                                alt="Incident Scene"
                                className="w-full h-full object-cover"
                                onError={() => setImageError(true)}
                            />
                        ) : (
                            <div className="flex flex-col items-center text-slate-600 gap-2">
                                <Camera size={48} />
                                <span className="text-xs font-mono uppercase">
                                    {imageError ? 'Image Load Failed' : 'No Evidence Image Uploaded'}
                                </span>
                            </div>
                        )}

                        {/* Overlay details */}
                        <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/90 to-transparent p-4 pt-12">
                            <h2 className="text-2xl font-bold text-white flex items-center gap-2">
                                {incident.incident_type}
                                <span className={`text-xs px-2 py-1 rounded border ${getSeverityConfig(incident.severity).bg} ${getSeverityConfig(incident.severity).color} ${getSeverityConfig(incident.severity).border}`}>
                                    SEVERITY LEVEL {incident.severity}
                                </span>
                            </h2>
                        </div>
                    </div>

                    {/* 2. Details Grid */}
                    <div className="grid grid-cols-2 gap-6">
                        {/* Left Col */}
                        <div className="space-y-4">
                            <div className="bg-slate-900/50 p-3 rounded border border-slate-800">
                                <label className="text-[10px] uppercase font-bold text-slate-500 block mb-1">Reported By</label>
                                <div className="flex items-center gap-2 text-slate-200">
                                    <User size={16} className="text-blue-500" />
                                    <span className="font-semibold">{incident.profiles?.full_name || 'Unknown Officer'}</span>
                                </div>
                            </div>

                            <div className="bg-slate-900/50 p-3 rounded border border-slate-800">
                                <label className="text-[10px] uppercase font-bold text-slate-500 block mb-1">Incident Time</label>
                                <div className="flex items-center gap-2 text-slate-200">
                                    <Clock size={16} className="text-amber-500" />
                                    <span className="font-mono">{new Date(incident.incident_time).toLocaleString()}</span>
                                </div>
                            </div>
                        </div>

                        {/* Right Col */}
                        <div className="space-y-4">
                            <div className="bg-slate-900/50 p-3 rounded border border-slate-800">
                                <label className="text-[10px] uppercase font-bold text-slate-500 block mb-1">Exact Location</label>
                                <div className="flex items-center gap-2 text-slate-200">
                                    <MapPin size={16} className="text-red-500" />
                                    <span className="font-mono">{incident.latitude.toFixed(6)}, {incident.longitude.toFixed(6)}</span>
                                </div>
                            </div>

                            <div className="bg-slate-900/50 p-3 rounded border border-slate-800">
                                <label className="text-[10px] uppercase font-bold text-slate-500 block mb-1">Victim Impact</label>
                                <div className="flex items-center gap-2 text-slate-200">
                                    <AlertCircle size={16} className="text-purple-500" />
                                    <span className="font-bold">{incident.victim_count} Individuals Affected</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Modal Footer (Actions) */}
                <div className="p-4 border-t border-slate-800 bg-slate-950 flex justify-end gap-3">
                    <button
                        onClick={onClose}
                        className="px-4 py-2 rounded text-slate-400 font-bold hover:text-white transition-colors"
                    >
                        CLOSE
                    </button>

                    {incident.status !== 'RESOLVED' && incident.status !== 'COMPLETED' && (
                        <button
                            onClick={() => onResolve(incident.id)}
                            className="px-6 py-2 rounded bg-emerald-600 hover:bg-emerald-700 text-white font-bold flex items-center gap-2 shadow-lg shadow-emerald-900/20 transition-all"
                        >
                            <Check size={18} />
                            MARK AS RESOLVED
                        </button>
                    )}
                </div>

            </div>
        </div>
    );
};