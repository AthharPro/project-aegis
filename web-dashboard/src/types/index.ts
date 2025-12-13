export type IncidentStatus = 'PENDING' | 'COMPLETED' | 'RESOLVED';

export interface Incident {
  id: string;
  user_id: string; // Links to the officer
  incident_type: string; // e.g., 'Fire', 'Accident', 'Flood'
  severity: number; // 1 = Low, 2 = Medium, 3 = High/Critical
  incident_time: string;
  victim_count: number;
  latitude: number;
  longitude: number;
  image_url: string | null;
  status: string; // 'OPEN', 'RESOLVED', etc.
  created_at: string;
  
  // This comes from the JOIN with the profiles table
  profiles?: {
    full_name: string;
    phone_number?: string;
  };
}

export interface Profile {
  id: string;
  full_name: string;
  nic: string;
  phone_number: string;
  role: 'admin' | 'dispatcher' | string;
  created_at: string;
}