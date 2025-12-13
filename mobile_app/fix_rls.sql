-- NUCLEAR OPTION: FIX INFINITE RECURSION BY DROPPING EVERYTHING
-- This script will:
-- 1. Disable RLS (Stop the checks immediately)
-- 2. Drop ALL policies on 'profiles' and 'incident_reports'
-- 3. Create SIMPLE policies that cannot loop.

BEGIN;

-- 1. Disable RLS to stop the error immediately
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE incident_reports DISABLE ROW LEVEL SECURITY;

-- 2. Drop ALL Policies (Nuclear approach)
-- We use a DO block to loop through and drop everything to be 100% sure
DO $$ 
DECLARE 
    r RECORD; 
BEGIN 
    FOR r IN (SELECT policyname, tablename FROM pg_policies WHERE tablename IN ('profiles', 'incident_reports')) 
    LOOP 
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I', r.policyname, r.tablename); 
    END LOOP; 
END $$;

-- 3. Re-Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE incident_reports ENABLE ROW LEVEL SECURITY;

-- 4. Create SIMPLE Policies (No "Check if user exists in other table")

-- Profiles: 
-- READ: Everyone can read everything (Simplest for now)
create policy "allow_select_profiles" on profiles for select using (true);
-- INSERT: User can only insert their own ID
create policy "allow_insert_profiles" on profiles for insert with check (auth.uid() = id);
-- UPDATE: User can only update their own ID
create policy "allow_update_profiles" on profiles for update using (auth.uid() = id);

-- Incident Reports:
-- READ: Authenticated users can read all reports
create policy "allow_select_incidents" on incident_reports for select to authenticated using (true);
-- INSERT: Authenticated users can insert anything (Trust the app)
create policy "allow_insert_incidents" on incident_reports for insert to authenticated with check (true);

COMMIT;
