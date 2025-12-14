import React, { useState } from 'react';
import { supabase } from '../services/supabaseClient';
import { Shield, Lock, Mail, Loader2, AlertCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const Login: React.FC = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const navigate = useNavigate(); // Hook to redirect

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError(null);
        try {
            const { error } = await supabase.auth.signInWithPassword({
                email,
                password,
            });

            if (error) {
                setError(error.message || 'Failed to authenticate');
                setLoading(false);
                return;
            }

            // Get the authenticated user id
            const userResult = await supabase.auth.getUser();
            const user = userResult.data.user;
            if (!user) {
                setError('Authentication succeeded but user not found');
                setLoading(false);
                return;
            }

            // Fetch role from profiles table
            const { data: profile, error: profileErr } = await supabase
                .from('profiles')
                .select('role')
                .eq('id', user.id)
                .single();

            if (profileErr) {
                console.error('Failed to fetch profile:', profileErr);
                setError('Unable to verify user role. Contact administrator.');
                // Sign out to be safe
                await supabase.auth.signOut();
                setLoading(false);
                return;
            }

            const role = profile?.role;
            if (role !== 'admin') {
                // Not an admin — deny access and sign out
                setError('Access denied — admin role required');
                await supabase.auth.signOut();
                setLoading(false);
                return;
            }

            // Role is admin — proceed to app
            navigate('/');

        } catch (err: any) {
            console.error('Login error:', err);
            setError(err?.message || 'An unexpected error occurred');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-slate-950 flex items-center justify-center p-4">
            <div className="w-full max-w-md bg-slate-900 border border-slate-800 rounded-lg shadow-2xl overflow-hidden">

                {/* Header */}
                <div className="bg-slate-900 p-8 text-center border-b border-slate-800">
                    <div className="w-16 h-16 bg-red-900 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg shadow-red-900/20">
                        <Shield className="w-8 h-8 text-white" />
                    </div>
                    <h1 className="text-2xl font-bold text-white tracking-tight">HQ LOGIN</h1>
                    <p className="text-slate-500 text-sm mt-2">RescueGo</p>
                </div>

                {/* Form */}
                <div className="p-8">
                    {error && (
                        <div className="mb-6 bg-red-500/10 border border-red-500/20 rounded p-3 flex items-center gap-3 text-red-400 text-sm">
                            <AlertCircle size={18} />
                            {error}
                        </div>
                    )}

                    <form onSubmit={handleLogin} className="space-y-4">
                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-500 uppercase">Official Email</label>
                            <div className="relative">
                                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500 w-4 h-4" />    
                                <input
                                    type="email"
                                    required
                                    className="w-full bg-slate-950 border border-slate-700 rounded-lg py-2.5 pl-10 pr-4 text-slate-200 focus:outline-none focus:border-red-500 transition-colors"
                                    placeholder="Enter your email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                />
                            </div>
                        </div>

                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-500 uppercase">Passcode</label>
                            <div className="relative">
                                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500 w-4 h-4" />
                                <input
                                    type="password"
                                    required
                                    className="w-full bg-slate-950 border border-slate-700 rounded-lg py-2.5 pl-10 pr-4 text-slate-200 focus:outline-none focus:border-red-500 transition-colors"
                                    placeholder="••••••••"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                />
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full bg-red-800 hover:bg-red-700 text-white font-bold py-3 rounded-lg transition-colors flex items-center justify-center gap-2 mt-6 shadow-lg shadow-red-900/20"
                        >
                            {loading ? <Loader2 className="animate-spin w-5 h-5" /> : 'AUTHENTICATE'}
                        </button>
                    </form>
                </div>

                {/* Footer */}
                <div className="bg-slate-950 p-4 text-center border-t border-slate-800">
                    <p className="text-xs text-slate-600 font-mono">AUTHORIZED PERSONNEL ONLY • ACCESS LOGGED</p>
                </div>
            </div>
        </div>
    );
};

export default Login;