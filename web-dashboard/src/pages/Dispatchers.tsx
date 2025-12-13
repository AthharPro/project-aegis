import React, { useState, useMemo } from 'react';
import { Search, Shield, Phone, CreditCard, User, UserPlus, X, Save, Loader2 } from 'lucide-react';
import { useOfficers } from '../hooks/useOfficers';

const Officers: React.FC = () => {
    const { officers, isLoading, addOfficer } = useOfficers();
    const [searchTerm, setSearchTerm] = useState('');

    // --- Modal State ---
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [formData, setFormData] = useState({
        email: '',
        full_name: '',
        nic: '',
        phone_number: '',
        role: 'responder'
    });

    // Filter Logic
    const filteredOfficers = useMemo(() => {
        return officers.filter(officer =>
            officer.full_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            officer.nic?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            officer.role?.toLowerCase().includes(searchTerm.toLowerCase())
        );
    }, [officers, searchTerm]);

    // Helper for Role Badges
    const getRoleBadge = (role: string) => {
        const r = role?.toUpperCase() || 'UNKNOWN';
        if (r === 'COMMANDER') return 'bg-purple-500/20 text-purple-400 border-purple-500/50';
        if (r === 'DISPATCH') return 'bg-blue-500/20 text-blue-400 border-blue-500/50';
        return 'bg-slate-500/20 text-slate-400 border-slate-500/50';
    };

    // --- Handlers ---
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        try {
            await addOfficer(formData);
            // Reset and Close
            setFormData({ email: ' ', full_name: '', nic: '', phone_number: '', role: 'responder' });
            setIsModalOpen(false);
        } catch (err) {
            alert('Failed to add officer. Check console for details.');
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="flex h-screen bg-slate-950 text-slate-100 overflow-hidden font-sans relative">
            <div className="flex-1 flex flex-col overflow-hidden">

                {/* Header */}
                <div className="bg-slate-900 border-b border-slate-800 px-6 py-4 flex justify-between items-center">
                    <div>
                        <h1 className="text-2xl font-bold tracking-tight">Personnel Management</h1>
                        <p className="text-sm text-slate-500">Active Duty Roster & Credentials</p>
                    </div>
                    <div className="flex gap-3">
                        {/* Add Officer Button */}
                        <button
                            onClick={() => setIsModalOpen(true)}
                            className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg flex items-center gap-2 text-sm font-bold transition-colors shadow-lg shadow-red-900/20"
                        >
                            <UserPlus size={16} />
                            ADD OFFICER
                        </button>
                    </div>
                </div>

                {/* Content */}
                <div className="flex-1 overflow-auto p-6 space-y-6">

                    {/* Search Bar */}
                    <div className="bg-slate-900/50 border border-slate-800 p-4 rounded-lg flex items-center gap-4">
                        <div className="relative flex-1">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500 w-4 h-4" />
                            <input
                                type="text"
                                placeholder="Search by Name, NIC, or Rank..."
                                className="w-full bg-slate-950 border border-slate-700 rounded pl-10 pr-4 py-2 text-sm text-slate-200 focus:outline-none focus:border-red-500 transition-colors placeholder:text-slate-600"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                            />
                        </div>
                    </div>

                    {/* Officers Grid/List */}
                    <div className="bg-slate-900/50 border border-slate-800 rounded-lg overflow-hidden min-h-[400px]">
                        <div className="grid grid-cols-12 gap-4 p-4 border-b border-slate-800 bg-slate-900/80 text-xs font-bold text-slate-500 uppercase tracking-wider">
                            <div className="col-span-4">Officer Details</div>
                            <div className="col-span-2">Rank / Role</div>
                            <div className="col-span-3">Contact Info</div>
                            <div className="col-span-3 text-right">Service ID (NIC)</div>
                        </div>

                        {isLoading ? (
                            <div className="p-12 text-center text-slate-500">Retrieving personnel records...</div>
                        ) : filteredOfficers.length === 0 ? (
                            <div className="p-12 text-center text-slate-500">No officers found.</div>
                        ) : (
                            filteredOfficers.map((officer) => (
                                <div key={officer.id} className="grid grid-cols-12 gap-4 p-4 border-b border-slate-800/50 hover:bg-slate-800 transition-colors items-center text-sm group">
                                    <div className="col-span-4 flex items-center gap-3">
                                        <div className="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center border border-slate-700 text-slate-400 group-hover:border-slate-600 group-hover:text-slate-200 transition-colors">
                                            <User size={20} />
                                        </div>
                                        <div>
                                            <div className="font-bold text-slate-200">{officer.full_name || 'Unknown Agent'}</div>
                                            <div className="text-[10px] text-slate-500 font-mono">ID: {officer.id.slice(0, 8)}...</div>
                                        </div>
                                    </div>
                                    <div className="col-span-2">
                                        <span className={`px-2 py-1 rounded text-[10px] font-bold border ${getRoleBadge(officer.role)}`}>
                                            {officer.role?.toUpperCase() || 'OFFICER'}
                                        </span>
                                    </div>
                                    <div className="col-span-3 flex items-center gap-2 text-slate-400">
                                        <Phone size={14} className="text-slate-600" />
                                        <span className="font-mono">{officer.phone_number || 'N/A'}</span>
                                    </div>
                                    <div className="col-span-3 text-right flex items-center justify-end gap-2 text-slate-400">
                                        <span className="font-mono tracking-wider">{officer.nic || 'Not Registered'}</span>
                                        <CreditCard size={14} className="text-slate-600" />
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </div>

            {/* --- ADD OFFICER MODAL --- */}
            {isModalOpen && (
                <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm">
                    <div className="bg-slate-900 border border-slate-700 w-full max-w-md rounded-lg shadow-2xl overflow-hidden">

                        {/* Modal Header */}
                        <div className="p-4 border-b border-slate-800 flex justify-between items-center bg-slate-900">
                            <h2 className="text-lg font-bold text-white flex items-center gap-2">
                                <UserPlus className="text-red-500" size={20} />
                                Register New Officer
                            </h2>
                            <button onClick={() => setIsModalOpen(false)} className="text-slate-500 hover:text-white">
                                <X size={20} />
                            </button>
                        </div>

                        {/* Modal Form */}
                        {/* Modal Form */}
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">

                            {/* 1. Email (Username) - CRITICAL: This was missing! */}
                            <div className="space-y-1">
                                <label className="text-xs font-bold text-slate-500 uppercase">Email (Login Username)</label>
                                <input
                                    required
                                    type="email"
                                    className="w-full bg-slate-950 border border-slate-700 rounded px-3 py-2 text-sm text-white focus:border-red-500 outline-none placeholder:text-slate-700"
                                    placeholder="officer@police.lk"
                                    value={formData.email}
                                    onChange={e => setFormData({ ...formData, email: e.target.value })}
                                />
                            </div>

                            {/* 2. Full Name */}
                            <div className="space-y-1">
                                <label className="text-xs font-bold text-slate-500 uppercase">Full Name</label>
                                <input
                                    required
                                    type="text"
                                    className="w-full bg-slate-950 border border-slate-700 rounded px-3 py-2 text-sm text-white focus:border-red-500 outline-none placeholder:text-slate-700"
                                    placeholder="e.g. Officer John Doe"
                                    value={formData.full_name}
                                    onChange={e => setFormData({ ...formData, full_name: e.target.value })}
                                />
                            </div>

                            {/* 3. NIC & Phone Row */}
                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-slate-500 uppercase">Service ID (NIC)</label>
                                    <input
                                        required
                                        type="text"
                                        className="w-full bg-slate-950 border border-slate-700 rounded px-3 py-2 text-sm text-white focus:border-red-500 outline-none placeholder:text-slate-700"
                                        placeholder="Password will be this"
                                        value={formData.nic}
                                        onChange={e => setFormData({ ...formData, nic: e.target.value })}
                                    />
                                </div>

                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-slate-500 uppercase">Phone</label>
                                    <input
                                        required
                                        type="tel"
                                        className="w-full bg-slate-950 border border-slate-700 rounded px-3 py-2 text-sm text-white focus:border-red-500 outline-none placeholder:text-slate-700"
                                        placeholder="077..."
                                        value={formData.phone_number}
                                        onChange={e => setFormData({ ...formData, phone_number: e.target.value })}
                                    />
                                </div>
                            </div>

                            {/* Action Buttons */}
                            <div className="pt-4 flex gap-3">
                                <button
                                    type="button"
                                    onClick={() => setIsModalOpen(false)}
                                    className="flex-1 py-2 rounded font-bold text-slate-400 hover:bg-slate-800 transition-colors text-sm"
                                >
                                    CANCEL
                                </button>
                                <button
                                    type="submit"
                                    disabled={isSubmitting}
                                    className="flex-1 py-2 rounded font-bold bg-red-600 hover:bg-red-700 text-white transition-colors text-sm flex items-center justify-center gap-2 shadow-lg shadow-red-900/20 disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    {isSubmitting ? <Loader2 className="animate-spin" size={16} /> : <Save size={16} />}
                                    SAVE RECORD
                                </button>
                            </div>

                        </form>
                    </div>
                </div>
            )}

        </div>
    );
};

export default Officers;