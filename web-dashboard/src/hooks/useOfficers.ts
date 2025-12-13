import { useEffect, useState } from 'react';
import { supabase } from '../services/supabaseClient';
import type { Profile } from '../types';

export const useOfficers = () => {
  const [officers, setOfficers] = useState<Profile[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchOfficers = async () => {
      // Fetch all profiles
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('full_name', { ascending: true });

      if (error) {
        console.error('Error fetching officers:', error);
      } else {
        setOfficers(data as Profile[]);
      }
      setIsLoading(false);
    };

    fetchOfficers();
  }, []);

  return { officers, isLoading };
};