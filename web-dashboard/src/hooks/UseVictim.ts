import { useEffect, useState } from 'react';
import { supabase } from '../services/supabaseClient';
import type { Incident, IncidentStatus } from '../types';

export const useIncidents = () => {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isConnected, setIsConnected] = useState(false); // 1. Add State

  // 2. Fetch Data
  useEffect(() => {
    const fetchIncidents = async () => {
      const { data, error } = await supabase
        .from('incident_reports')
        .select(`*, profiles ( full_name, phone_number )`)
        .order('incident_time', { ascending: false });

      if (!error && data) setIncidents(data as Incident[]);
      setIsLoading(false);
    };

    fetchIncidents();

    // 3. Realtime Listener
    const channel = supabase
      .channel('realtime-incidents')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'incident_reports' }, 
        async (payload) => {
          if (payload.eventType === 'INSERT') {
            // FIX: Fetch the officer name for the new incident
            // (Realtime payloads don't include joined table data automatically)
            const newIncident = payload.new as Incident;
            
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
            // Status update happened!
            // We merge payload.new into the existing item to keep the profile data intact
            setIncidents((prev) => prev.map(i => i.id === payload.new.id ? { ...i, ...payload.new } : i));
          }
        }
      )
      .subscribe((status) => {
        // 4. Update Connection Status
        setIsConnected(status === 'SUBSCRIBED');
      });

    return () => { supabase.removeChannel(channel); };
  }, []);

  // 5. ACTION: Update Status (The "HQ Command" function)
  const updateStatus = async (id: string, newStatus: IncidentStatus) => {
    // Optimistic Update (Update UI immediately for speed)
    setIncidents(prev => prev.map(i => i.id === id ? { ...i, status: newStatus } : i));

    // Send to DB
    const { error } = await supabase
      .from('incident_reports')
      .update({ status: newStatus })
      .eq('id', id);

    if (error) {
      console.error('Failed to update status:', error);
    }
  };

  return { incidents, updateStatus, isLoading, isConnected };
};