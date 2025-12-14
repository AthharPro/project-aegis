import React, { useState, useEffect } from 'react';
import { Pagination, ConfigProvider, theme } from 'antd';
import { Search, Filter, MapPin, User, AlertCircle, Clock, Check, X, Camera, XCircle, Image as ImageIcon } from 'lucide-react';
import { useIncidentsPaginated } from '../hooks/UseIncidentsPaginated';
import { getSeverityConfig, getStatusConfig, formatTimestamp, formatVictimCount } from '../utils/helper';
import type { Incident } from '../types';
import { IncidentModal } from '../components/IncidentModel';

const AllRequests: React.FC = () => {
  // --- Filter & Pagination States ---
  const [searchTerm, setSearchTerm] = useState('');
  const [severityFilter, setSeverityFilter] = useState<string>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [confirmingId, setConfirmingId] = useState<string | null>(null);

  // --- NEW: State for the Popup Modal ---
  const [selectedIncident, setSelectedIncident] = useState<Incident | null>(null);

  const pageSize = 8;

  const { incidents, total, isLoading, updateStatus } = useIncidentsPaginated({
    page: currentPage,
    pageSize,
    searchTerm,
    severityFilter,
  });

  // Handle Resolution (Reused for both Row and Modal)
  const handleResolve = (id: string) => {
    updateStatus(id, 'RESOLVED');
    setConfirmingId(null);
    if (selectedIncident?.id === id) {
      // Close modal if resolving from within modal
      setSelectedIncident(null);
    }
    setTimeout(() => {
      updateStatus(id, 'COMPLETED');
    }, 2000);
  };

  // Reset page on filter change
  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, severityFilter]);

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  return (
    <div className="flex h-screen bg-slate-950 text-slate-100 overflow-hidden font-sans relative">
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="bg-slate-900 border-b border-slate-800 px-6 py-4 flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Mission Logs</h1>
            <p className="text-sm text-slate-500">Master database of all incident reports</p>
          </div>
          <div className="text-xs font-mono text-slate-500 bg-slate-800 px-3 py-1 rounded border border-slate-700">
            TOTAL RECORDS: {total}
          </div>
        </div>

        <div className="flex-1 overflow-auto p-6 space-y-6">
          {/* Filters Bar */}
          <div className="bg-slate-900/50 border border-slate-800 p-4 rounded-lg flex flex-col md:flex-row gap-4 items-center justify-between backdrop-blur-sm">
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
            <div className="flex gap-4 w-full md:w-auto">
              <div className="relative">
                <select
                  className="appearance-none bg-slate-950 border border-slate-700 text-slate-300 py-2 pl-4 pr-10 rounded text-sm focus:outline-none focus:border-blue-500 cursor-pointer"
                  value={severityFilter}
                  onChange={(e) => setSeverityFilter(e.target.value)}
                >
                  <option value="all">All Severities</option>
                  <option value="Critical">Critical (Lvl 5)</option>
                  <option value="High">High (Lvl 4)</option>
                  <option value="Moderate">Moderate (Lvl 3)</option>
                  <option value="Minor">Minor (Lvl 2)</option>
                  <option value="Low">Low (Lvl 1)</option>
                </select>
                <Filter className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-500 w-3 h-3 pointer-events-none" />
              </div>
            </div>
          </div>

          {/* Table Content */}
          <div className="bg-slate-900/50 border border-slate-800 rounded-lg overflow-hidden flex flex-col min-h-[600px]">
            <div className="grid grid-cols-12 gap-4 p-4 border-b border-slate-800 bg-slate-900/80 text-xs font-bold text-slate-500 uppercase tracking-wider">
              <div className="col-span-3">Incident Type</div>
              <div className="col-span-1">Severity</div>
              <div className="col-span-2">HQ Status</div>
              <div className="col-span-3">Location</div>
              <div className="col-span-1 text-center">Victims</div>
              <div className="col-span-2 text-right">Responder / Time</div>
            </div>

            <div className="flex-1">
              {isLoading ? (
                <div className="p-8 text-center text-slate-500">Loading records...</div>
              ) : incidents.length === 0 ? (
                <div className="p-8 text-center text-slate-500">No records found matching your filters.</div>
              ) : (
                incidents.map((incident: Incident) => {
                  const severityConfig = getSeverityConfig(incident.severity);
                  const statusConfig = getStatusConfig(incident.status);

                  return (
                    <div
                      key={incident.id}
                      onClick={() => setSelectedIncident(incident)} // <--- OPEN POPUP ON CLICK
                      className="grid grid-cols-12 gap-4 p-4 border-b border-slate-800/50 hover:bg-slate-800 transition-colors items-center text-sm group cursor-pointer"
                    >
                      {/* ... (Columns same as before) ... */}
                      <div className="col-span-3 font-medium text-slate-200 flex items-center gap-3">
                        {/* Severity Dot */}
                        <div className={`w-2 h-2 rounded-full ${severityConfig.bg.replace('/20', '')} shadow-[0_0_8px_rgba(255,255,255,0.2)]`}></div>

                        <div className="flex items-center gap-2">
                          <span>{incident.incident_type}</span>

                          {/* IMAGE INDICATOR ICON */}
                          {incident.image_url && (
                            <div className="flex items-center justify-center w-4 h-4 rounded bg-slate-800 border border-slate-700 text-slate-400" title="Evidence Image Available">
                              <ImageIcon size={10} />
                            </div>
                          )}
                        </div>
                      </div>

                      <div className="col-span-1">
                        <span className={`px-2 py-1 rounded border text-[10px] font-bold ${severityConfig.color} ${severityConfig.bg} ${severityConfig.border}`}>
                          {severityConfig.label}
                        </span>
                      </div>

                      <div className="col-span-2">
                        <div className="flex flex-row gap-2 items-center">
                          <span className={`flex items-center gap-1.5 w-fit px-2 py-1 rounded text-[10px] font-bold ${statusConfig.color} ${statusConfig.bg}`}>
                            {incident.status === 'PENDING' && <AlertCircle size={10} />}
                            {statusConfig.label.toUpperCase()}
                          </span>

                          {/* Action Button (Prevent Bubble Up) */}
                          {confirmingId === incident.id ? (
                            <div className="flex items-center gap-2">
                              <button
                                onClick={(e) => { e.stopPropagation(); handleResolve(incident.id); }}
                                className="w-8 h-8 p-1 rounded-sm bg-emerald-600 hover:bg-emerald-700 text-white transition-colors shadow-sm flex items-center justify-center"
                              >
                                <Check size={14} />
                              </button>
                              <button
                                onClick={(e) => { e.stopPropagation(); setConfirmingId(null); }}
                                className="w-8 h-8 p-1 rounded-sm bg-red-600 hover:bg-red-700 text-white transition-colors shadow-sm flex items-center justify-center"
                              >
                                <X size={14} />
                              </button>
                            </div>
                          ) : incident.status.toUpperCase() === 'RESOLVED' ? (
                            <div className="w-12 h-8"></div>
                          ) : (
                            <button
                              onClick={(e) => { e.stopPropagation(); setConfirmingId(incident.id); }}
                              className="flex items-center gap-1.5 w-fit px-3 py-1.5 rounded text-[10px] font-bold bg-slate-800 text-slate-300 border border-slate-600 hover:bg-emerald-600 hover:text-white hover:border-emerald-500 transition-all shadow-sm"
                            >
                              <div className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
                              MARK RESOLVED
                            </button>
                          )}
                        </div>
                      </div>

                      <div className="col-span-3 text-slate-400 font-mono text-xs flex items-center gap-2">
                        <MapPin className="w-3 h-3 text-slate-600" />
                        {incident.latitude.toFixed(4)}, {incident.longitude.toFixed(4)}
                      </div>

                      <div className="col-span-1 text-slate-400 font-mono text-xs flex justify-center items-center">
                        <span className="text-sm font-bold text-slate-300">
                          {formatVictimCount(incident.victim_count)}
                        </span>
                      </div>

                      <div className="col-span-2 text-right flex flex-col items-end gap-1">
                        <div className="text-slate-300 flex items-center gap-1.5" title={incident.user_id}>
                          <span className="w-[120px] truncate">{incident.profiles?.full_name || 'Unknown'}</span>
                          <User className="w-3 h-3 text-slate-600" />
                        </div>
                        <div className="text-slate-500 font-mono text-[14px] flex items-center gap-1">
                          {formatTimestamp(incident.incident_time)}
                          <Clock className="w-3 h-3" />
                        </div>
                      </div>
                    </div>
                  );
                })
              )}
            </div>

            <div className="p-4 border-t border-slate-800 bg-slate-900/50 flex justify-end">
              <ConfigProvider
                theme={{
                  algorithm: theme.darkAlgorithm,
                  token: { colorPrimary: '#ef4444', colorBgContainer: '#1e293b', colorBorder: '#334155' },
                }}
              >
                <Pagination
                  current={currentPage}
                  total={total}
                  pageSize={pageSize}
                  onChange={handlePageChange}
                  showSizeChanger={false}
                />
              </ConfigProvider>
            </div>
          </div>
        </div>
      </div>

      {/* --- INCIDENT DETAILS MODAL --- */}
      <IncidentModal
        incident={selectedIncident}
        onClose={() => setSelectedIncident(null)}
        onResolve={handleResolve}
      />

    </div>
  );
};

export default AllRequests;