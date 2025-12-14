export type IncidentStatus = 'PENDING' | 'RESOLVED' | 'COMPLETED' ;

export interface Incident {
  id: string;
  user_id: string;
  incident_type: string; 
  severity: number;
  incident_time: string;
  victim_count: number;
  latitude: number;
  longitude: number;
  image_url: string | null;
  status: string;
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