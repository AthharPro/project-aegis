import React, { useState, useMemo } from 'react';
import { Pagination, ConfigProvider, theme } from 'antd';
import { Search, Filter, MapPin, User, AlertCircle, Clock, Check, X } from 'lucide-react';
import { useIncidents } from '../hooks/UseVictim';
import { getSeverityConfig, getStatusConfig, formatTimestamp, formatVictimCount } from '../utils/helper';
import type { Incident } from '../types';

const AllRequests: React.FC = () => {
    const { completedIncidents, isLoading } = useIncidents();

    // --- Filter States ---
    const [searchTerm, setSearchTerm] = useState('');
    const [severityFilter, setSeverityFilter] = useState<string>('all');
    const [currentPage, setCurrentPage] = useState(1);
    const pageSize = 8;

    // --- Filtering Logic ---
    const filteredData = useMemo(() => {
        return completedIncidents.filter(incident => {
            const searchLower = searchTerm.toLowerCase();
            const officerName = incident.profiles?.full_name?.toLowerCase() || '';

            const matchesSearch =
                incident.incident_type.toLowerCase().includes(searchLower) ||
                officerName.includes(searchLower) ||
                `${incident.latitude}, ${incident.longitude}`.includes(searchLower);

            let matchesSeverity = true;
            if (severityFilter !== 'all') {
                if (severityFilter === 'Critical') matchesSeverity = incident.severity >= 4;
                else if (severityFilter === 'High') matchesSeverity = incident.severity === 3;
                else if (severityFilter === 'Moderate') matchesSeverity = incident.severity === 2;
                else if (severityFilter === 'Low') matchesSeverity = incident.severity === 1;
            }

            return matchesSearch && matchesSeverity;
        });
    }, [completedIncidents, searchTerm, severityFilter]);

    // --- Pagination Logic ---
    const currentData = useMemo(() => {
        const start = (currentPage - 1) * pageSize;
        return filteredData.slice(start, start + pageSize);
    }, [filteredData, currentPage]);

    const handlePageChange = (page: number) => {
        setCurrentPage(page);
    };

    return (
        <div className="flex h-screen bg-slate-950 text-slate-100 overflow-hidden font-sans">
            <div className="flex-1 flex flex-col overflow-hidden">
                {/* Header */}
                <div className="bg-slate-900 border-b border-slate-800 px-6 py-4 flex justify-between items-center">
                    <div>
                        <h1 className="text-2xl font-bold tracking-tight">Mission Logs</h1>
                        <p className="text-sm text-slate-500">Master database of all incident reports</p>
                    </div>
                    <div className="text-xs font-mono text-slate-500 bg-slate-800 px-3 py-1 rounded border border-slate-700">
                        TOTAL RECORDS: {completedIncidents.length}
                    </div>
                </div>

                <div className="flex-1 overflow-auto p-6 space-y-6">
                    {/* --- FILTERS BAR --- */}
                    <div className="bg-slate-900/50 border border-slate-800 p-4 rounded-lg flex flex-col md:flex-row gap-4 items-center justify-between backdrop-blur-sm">
                        {/* Left: Search */}
                        <div className="relative w-full md:w-96">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500 w-4 h-4" />
                            <input
                                type="text"
                                placeholder="Search type, officer name, or coordinates..."
                                className="w-full bg-slate-950 border border-slate-700 rounded pl-10 pr-4 py-2 text-sm text-slate-200 focus:outline-none focus:border-blue-500 transition-colors placeholder:text-slate-600"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                            />
                        </div>

                        {/* Right: Dropdowns */}
                        <div className="flex gap-4 w-full md:w-auto">
                            <div className="relative">
                                <select
                                    className="appearance-none bg-slate-950 border border-slate-700 text-slate-300 py-2 pl-4 pr-10 rounded text-sm focus:outline-none focus:border-blue-500 cursor-pointer"
                                    value={severityFilter}
                                    onChange={(e) => setSeverityFilter(e.target.value)}
                                >
                                    <option value="all">All Severities</option>
                                    <option value="Critical">Critical (Lvl 4-5)</option>
                                    <option value="High">High (Lvl 3)</option>
                                    <option value="Moderate">Moderate (Lvl 2)</option>
                                    <option value="Low">Low (Lvl 1)</option>
                                </select>
                                <Filter className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-500 w-3 h-3 pointer-events-none" />
                            </div>
                        </div>
                    </div>

                    {/* --- TABLE CONTENT --- */}
                    <div className="bg-slate-900/50 border border-slate-800 rounded-lg overflow-hidden flex flex-col min-h-[600px]">
                        {/* Table Header */}
                        <div className="grid grid-cols-12 gap-4 p-4 border-b border-slate-800 bg-slate-900/80 text-xs font-bold text-slate-500 uppercase tracking-wider">
                            <div className="col-span-3">Incident Type</div>
                            <div className="col-span-2">Severity</div>
                            <div className="col-span-2">HQ Status</div>
                            <div className="col-span-3">Location</div>
                            <div className="col-span-2 text-right">Officer / Time</div>
                        </div>

                        {/* Table Rows */}
                        <div className="flex-1">
                            {isLoading ? (
                                <div className="p-8 text-center text-slate-500">Loading records...</div>
                            ) : currentData.length === 0 ? (
                                <div className="p-8 text-center text-slate-500">No records found matching your filters.</div>
                            ) : (
                                currentData.map((incident: Incident) => {
                                    const severityConfig = getSeverityConfig(incident.severity);
                                    const statusConfig = getStatusConfig(incident.status);

                                    return (
                                        <div
                                            key={incident.id}
                                            className="grid grid-cols-12 gap-4 p-4 border-b border-slate-800/50 hover:bg-slate-800/50 transition-colors items-center text-sm group"
                                        >
                                            {/* Incident Type */}
                                            <div className="col-span-3 font-medium text-slate-200 flex items-center gap-3">
                                                <div className={`w-2 h-2 rounded-full ${severityConfig.bg.replace('/20', '')} shadow-[0_0_8px_rgba(255,255,255,0.2)]`}></div>
                                                <div className="flex flex-col">
                                                    <span>{incident.incident_type}</span>
                                                    {incident.victim_count > 0 && (
                                                        <span className="text-[10px] text-slate-500">{formatVictimCount(incident.victim_count)} Victims</span>
                                                    )}
                                                </div>
                                            </div>

                                            {/* Severity Badge */}
                                            <div className="col-span-2">
                                                <span className={`px-2 py-1 rounded border text-[10px] font-bold ${severityConfig.color} ${severityConfig.bg} ${severityConfig.border}`}>
                                                    {severityConfig.label}
                                                </span>
                                            </div>

                                            {/* Status Badge */}
                                            <div className="col-span-2">
                                                <span className={`flex items-center gap-1.5 w-fit px-2 py-1 rounded text-[10px] font-bold ${statusConfig.color} ${statusConfig.bg}`}>
                                                    {incident.status === 'PENDING' && <AlertCircle size={10} />}
                                                    {statusConfig.label.toUpperCase()}
                                                </span>

                                            </div>

                                            {/* Location */}
                                            <div className="col-span-3 text-slate-400 font-mono text-xs flex items-center gap-2">
                                                <MapPin className="w-3 h-3 text-slate-600" />
                                                {incident.latitude.toFixed(4)}, {incident.longitude.toFixed(4)}
                                            </div>

                                            {/* Officer & Time */}
                                            <div className="col-span-2 text-right flex flex-col items-end gap-1">
                                                <div className="text-slate-300 flex items-center gap-1.5" title={incident.user_id}>
                                                    <span className="truncate max-w-[100px]">{incident.profiles?.full_name || 'Unknown'}</span>
                                                    <User className="w-3 h-3 text-slate-600" />
                                                </div>
                                                <div className="text-slate-500 font-mono text-[10px] flex items-center gap-1">
                                                    {formatTimestamp(incident.incident_time)}
                                                    <Clock className="w-3 h-3" />
                                                </div>
                                            </div>
                                        </div>
                                    );
                                })
                            )}
                        </div>

                        {/* --- PAGINATION FOOTER --- */}
                        <div className="p-4 border-t border-slate-800 bg-slate-900/50 flex justify-end">
                            <ConfigProvider
                                theme={{
                                    algorithm: theme.darkAlgorithm,
                                    token: {
                                        colorPrimary: '#ef4444',
                                        colorBgContainer: '#1e293b',
                                        colorBorder: '#334155',
                                    },
                                }}
                            >
                                <Pagination
                                    current={currentPage}
                                    total={filteredData.length}
                                    pageSize={pageSize}
                                    onChange={handlePageChange}
                                    showSizeChanger={false}
                                />
                            </ConfigProvider>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AllRequests;