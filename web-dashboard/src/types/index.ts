export interface Victim {
  id: string;
  full_name: string;
  injury_status: 'Critical' | 'Stable' | 'Deceased';
  gps_lat: number;
  gps_long: number;
  officer_id: string;
  created_at: string;
  synced_at?: string; // Optional field to track sync time
}