import { createClient } from '@supabase/supabase-js';

// 1. Load variables from the .env file
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// 2. Validate that they exist (Helps debug deployment issues later)
if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase Environment Variables. Check your .env file.');
}

// 3. Export the client to be used throughout the app
export const supabase = createClient(supabaseUrl, supabaseAnonKey);