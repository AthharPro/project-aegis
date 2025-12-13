import { useState, useEffect } from 'react';
import  type{ Victim } from '../types';

const MOCK_VICTIMS: Victim[] = [
  { id: '1', full_name: 'John Anderson', injury_status: 'Critical', gps_lat: 6.9271, gps_long: 79.8612, created_at: new Date(Date.now() - 120000).toISOString(), officer_id: 'off-001' },
  { id: '2', full_name: 'Sarah Mitchell', injury_status: 'Stable', gps_lat: 6.9155, gps_long: 79.8750, created_at: new Date(Date.now() - 300000).toISOString(), officer_id: 'off-002' },
  { id: '3', full_name: 'Michael Chen', injury_status: 'Critical', gps_lat: 6.9350, gps_long: 79.8500, created_at: new Date(Date.now() - 450000).toISOString(), officer_id: 'off-003' },
  { id: '4', full_name: 'Emma Rodriguez', injury_status: 'Stable', gps_lat: 6.9100, gps_long: 79.8650, created_at: new Date(Date.now() - 600000).toISOString(), officer_id: 'off-001' },
  { id: '5', full_name: 'David Thompson', injury_status: 'Deceased', gps_lat: 6.9200, gps_long: 79.8550, created_at: new Date(Date.now() - 900000).toISOString(), officer_id: 'off-004' }
];

export const useVictims = () => {
  const [victims, setVictims] = useState<Victim[]>([]);
  const [isConnected, setIsConnected] = useState(true);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Simulate initial load
    setTimeout(() => {
      setVictims(MOCK_VICTIMS);
      setIsLoading(false);
    }, 800);

    // Simulate realtime updates
    const interval = setInterval(() => {
      const newVictim: Victim = {
        id: `mock-${Date.now()}`,
        full_name: ['Alex Parker', 'Maria Santos', 'James Wilson', 'Lisa Brown', 'Robert Taylor'][Math.floor(Math.random() * 5)],
        injury_status: ['Critical', 'Stable', 'Deceased'][Math.floor(Math.random() * 3)] as any,
        gps_lat: 6.9271 + (Math.random() - 0.5) * 0.05,
        gps_long: 79.8612 + (Math.random() - 0.5) * 0.05,
        created_at: new Date().toISOString(),
        officer_id: `off-00${Math.floor(Math.random() * 5) + 1}`
      };
      setVictims(prev => [newVictim, ...prev]);
    }, 15000);

    // Simulate connection drops
    const connectionInterval = setInterval(() => {
      setIsConnected(prev => Math.random() > 0.1 ? true : prev);
    }, 5000);

    return () => {
      clearInterval(interval);
      clearInterval(connectionInterval);
    };
  }, []);

  return { victims, isConnected, isLoading };
};