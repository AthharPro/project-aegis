import { useEffect, useState, useCallback } from 'react';
import { supabase } from '../services/supabaseClient';
import type { Profile } from '../types';

interface NewOfficerData {
    email: string;      // Required for login
    nic: string;        // Will be used as the password
    full_name: string;
    phone_number: string;
    role: string;
}

export const useOfficers = () => {
    const [officers, setOfficers] = useState<Profile[]>([]);
    const [isLoading, setIsLoading] = useState(true);

    // 1. Define the fetch function OUTSIDE useEffect so it can be reused
    const fetchOfficers = useCallback(async () => {
        setIsLoading(true);
        const { data, error } = await supabase
            .from('profiles')
            .select('*')
            .order('full_name', { ascending: true });

        if (error) {
            console.error('Error fetching officers:', error);
        } else if (data) {
            setOfficers(data as Profile[]);
        }
        setIsLoading(false);
    }, []);

    // 2. Call it on mount
    useEffect(() => {
        fetchOfficers();
    }, [fetchOfficers]);

    // 3. Add Officer Function
    const addOfficer = async (newOfficer: NewOfficerData) => {

        // We pass the email and NIC. The backend handles setting the password.
        const { data, error } = await supabase.functions.invoke('create-officer', {
            body: newOfficer
        });

        if (error) {
            console.error('Error creating officer:', error);
            throw error;
        }

        if (data) {
            setOfficers(prev => [...prev, data as Profile]);
        }
        return data;
    };

    // 4. Return everything, including the fix for 'refreshOfficers'
    return { officers, isLoading, addOfficer, refreshOfficers: fetchOfficers };
};