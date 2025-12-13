import { useEffect, useState, useCallback } from 'react';
import { supabase } from '../services/supabaseClient';
import type { Incident, IncidentStatus } from '../types';

interface Params {
  page: number;
  pageSize: number;
  searchTerm?: string;
  severityFilter?: string;
}

export const useIncidentsPaginated = ({ page, pageSize, searchTerm = '', severityFilter = 'all' }: Params) => {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [total, setTotal] = useState<number>(0);
  const [isLoading, setIsLoading] = useState(true);

  const fetchPage = useCallback(async () => {
    setIsLoading(true);

    const start = (page - 1) * pageSize;
    const end = start + pageSize - 1;

    try {
      let query: any = supabase
        .from('incident_reports')
        .select('*, profiles ( full_name, phone_number )', { count: 'exact' })
        .neq('status', 'completed')
        .order('incident_time', { ascending: false })
        .range(start, end);

      // Apply severity filter server-side when possible
      if (severityFilter && severityFilter !== 'all') {
        if (severityFilter === 'Critical') query = query.gte('severity', 4);
        else if (severityFilter === 'High') query = query.eq('severity', 3);
        else if (severityFilter === 'Moderate') query = query.eq('severity', 2);
        else if (severityFilter === 'Low') query = query.eq('severity', 1);
      }

      // Basic server-side search on incident_type
      if (searchTerm && searchTerm.trim().length > 0) {
        const term = `%${searchTerm.trim()}%`;
        query = query.ilike('incident_type', term);
      }

      const { data, error, count } = await query;

      if (error) {
        console.error('Paginated fetch error:', error);
        setIncidents([]);
        setTotal(0);
      } else {
        setIncidents((data || []) as Incident[]);
        setTotal(typeof count === 'number' ? count : (data || []).length);
      }
    } catch (err) {
      console.error('Unexpected fetch error:', err);
      setIncidents([]);
      setTotal(0);
    } finally {
      setIsLoading(false);
    }
  }, [page, pageSize, searchTerm, severityFilter]);

  useEffect(() => {
    fetchPage();
  }, [fetchPage]);

  // Listen for realtime changes and refetch current page when relevant
  useEffect(() => {
    const channel = supabase
      .channel('realtime-incidents-paginated')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'incident_reports' }, async (payload) => {
        // For simplicity: refetch the current page on any change
        fetchPage();
      })
      .subscribe(() => {});

    return () => { supabase.removeChannel(channel); };
  }, [fetchPage]);

  const updateStatus = async (id: string, newStatus: IncidentStatus) => {
    const dbStatus = newStatus.toLowerCase();

    // Optimistic update for the current page
    if (dbStatus === 'completed') {
      setIncidents(prev => prev.filter(i => i.id !== id));
      setTotal(prev => (prev > 0 ? prev - 1 : 0));
    } else {
      setIncidents(prev => prev.map(i => i.id === id ? { ...i, status: newStatus } : i));
    }

    const { error } = await supabase
      .from('incident_reports')
      .update({ status: dbStatus })
      .eq('id', id);

    if (error) {
      console.error('Failed to update status:', error);
      // If desired, refetch current page to reconcile
      fetchPage();
    }
  };

  return { incidents, total, isLoading, updateStatus, refetchPage: fetchPage };
};
