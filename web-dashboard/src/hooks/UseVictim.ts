import { useEffect, useState } from 'react';
import { supabase } from '../services/supabaseClient';
import type { Incident, IncidentStatus } from '../types';

export const useIncidents = () => {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isConnected, setIsConnected] = useState(false); // 1. Add State
  const [completedIncidents, setCompletedIncidents] = useState<Incident[]>([]);

  // 2. Fetch Data
  useEffect(() => {
    const fetchIncidents = async () => {

      console.log('🔄 Attempting to fetch initial data...');

      const { data, error } = await supabase
        .from('incident_reports')
        .select(`*, profiles ( full_name, phone_number )`)
        .neq('status', 'completed')
        .order('incident_time', { ascending: false });

      //DEBUG 2
      if (error) {
        console.error('❌ Supabase Fetch Error:', error);
      } else {
        console.log('✅ Initial Data Received:', data); // <--- CHECK THIS IN CONSOLE
      }

      if (!error && data) setIncidents(data as Incident[]);
      setIsLoading(false);
    };

    fetchIncidents();

    const fetchCompletedIncidents = async () => {

      const { data, error } = await supabase
        .from('incident_reports')
        .select(`*, profiles ( full_name, phone_number )`)
        .eq('status', 'completed')
        .order('incident_time', { ascending: false });

      if (error) {
        console.error('❌ Supabase Fetch Error:', error);
      } else {
        console.log('✅ Initial Data Received:', data); // <--- CHECK THIS IN CONSOLE
      }

      if (!error && data) setCompletedIncidents(data as Incident[]);
      setIsLoading(false);
    };

    fetchCompletedIncidents();

    // 3. Realtime Listener
    const channel = supabase
      .channel('realtime-incidents')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'incident_reports' },
        async (payload) => {

          //DEBUG 3
          console.log('📡 Realtime Payload:', payload);

          if (payload.eventType === 'INSERT') {
            // FIX: Fetch the officer name for the new incident
            // (Realtime payloads don't include joined table data automatically)
            const newIncident = payload.new as Incident;

            // Log specifically what row was just added
            console.log('➕ New Row Inserted:', newIncident);

            const { data: profile } = await supabase
              .from('profiles')
              .select('full_name, phone_number')
              .eq('id', newIncident.user_id)
              .single();

            const incidentWithProfile = {
              ...newIncident,
              profiles: profile || { full_name: 'Unknown Officer' }
            };

            setIncidents((prev) => [incidentWithProfile as Incident, ...prev]);

          } else if (payload.eventType === 'UPDATE') {
            setIncidents((prev) => prev.map(i => i.id === payload.new.id ? { ...i, ...payload.new } : i));
          }
        }
      )
      .subscribe((status) => {

        // DEBUG 4: Check if the socket actually connected
        console.log('🔌 Connection Status Change:', status);

        // 4. Update Connection Status
        setIsConnected(status === 'SUBSCRIBED');
      });

    return () => { supabase.removeChannel(channel); };
  }, []);

  // 5. ACTION: Update Status (The "HQ Command" function)
  const updateStatus = async (id: string, newStatus: IncidentStatus) => {
    const dbStatus = newStatus.toLowerCase(); // Ensure lowercase for DB

    // OPTIMISTIC UPDATE:
    if (dbStatus === 'completed') {
      // If completed, REMOVE it from the screen immediately
      setIncidents(prev => prev.filter(i => i.id !== id));
    } else {
      // If just changing to 'resolved' or 'pending', keep it but update text
      setIncidents(prev => prev.map(i => i.id === id ? { ...i, status: newStatus } : i));
    }

    // DATABASE CALL:
    const { error } = await supabase
      .from('incident_reports')
      .update({ status: dbStatus })
      .eq('id', id);

    if (error) {
      console.error('Failed to update status:', error);
      // Optional: Fetch data again to revert changes if DB fails
    }
  };

  return { incidents, updateStatus, isLoading, isConnected, completedIncidents };
};