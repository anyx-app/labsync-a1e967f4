-- Migration: Initial Schema Setup for LabSync
-- Schema: proj_29b43923

SET search_path TO proj_29b43923;

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. PROFILES
-- Extended user information linked to auth.users (handled via trigger usually, or manual creation)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY, -- References auth.users.id manually
    email TEXT NOT NULL,
    full_name TEXT,
    role TEXT CHECK (role IN ('researcher', 'manager', 'admin')),
    department TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by everyone" 
    ON profiles FOR SELECT 
    USING (true);

CREATE POLICY "Users can insert their own profile" 
    ON profiles FOR INSERT 
    WITH CHECK (id::text = current_setting('request.jwt.claims', true)::json->>'sub');

CREATE POLICY "Users can update their own profile" 
    ON profiles FOR UPDATE 
    USING (id::text = current_setting('request.jwt.claims', true)::json->>'sub');

-- 2. EQUIPMENT
-- Inventory of lab equipment
CREATE TABLE IF NOT EXISTS equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    model_number TEXT,
    serial_number TEXT,
    status TEXT CHECK (status IN ('available', 'maintenance', 'retired')) DEFAULT 'available',
    location TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Equipment
ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Equipment is viewable by everyone" 
    ON equipment FOR SELECT 
    USING (true);

CREATE POLICY "Managers and Admins can manage equipment" 
    ON equipment FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id::text = current_setting('request.jwt.claims', true)::json->>'sub'
            AND profiles.role IN ('manager', 'admin')
        )
    );

-- 3. BOOKINGS
-- Reservations of equipment
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    equipment_id UUID REFERENCES equipment(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    purpose TEXT,
    status TEXT CHECK (status IN ('confirmed', 'cancelled', 'completed')) DEFAULT 'confirmed',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Bookings
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Bookings are viewable by everyone" 
    ON bookings FOR SELECT 
    USING (true);

CREATE POLICY "Users can create their own bookings" 
    ON bookings FOR INSERT 
    WITH CHECK (user_id::text = current_setting('request.jwt.claims', true)::json->>'sub');

CREATE POLICY "Users can update their own bookings" 
    ON bookings FOR UPDATE 
    USING (user_id::text = current_setting('request.jwt.claims', true)::json->>'sub');

CREATE POLICY "Managers can manage all bookings" 
    ON bookings FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id::text = current_setting('request.jwt.claims', true)::json->>'sub'
            AND profiles.role IN ('manager', 'admin')
        )
    );

-- 4. MAINTENANCE LOGS
-- Maintenance history
CREATE TABLE IF NOT EXISTS maintenance_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    equipment_id UUID REFERENCES equipment(id) ON DELETE CASCADE,
    performed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    description TEXT NOT NULL,
    date_performed TIMESTAMPTZ DEFAULT NOW(),
    next_maintenance_due TIMESTAMPTZ,
    cost NUMERIC,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Maintenance Logs
ALTER TABLE maintenance_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Maintenance logs viewable by everyone" 
    ON maintenance_logs FOR SELECT 
    USING (true);

CREATE POLICY "Managers and Admins can manage maintenance logs" 
    ON maintenance_logs FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id::text = current_setting('request.jwt.claims', true)::json->>'sub'
            AND profiles.role IN ('manager', 'admin')
        )
    );

-- 5. PROTOCOLS
-- Standard operating procedures
CREATE TABLE IF NOT EXISTS protocols (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    content TEXT, -- Markdown or JSON content
    author_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    is_public BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Protocols
ALTER TABLE protocols ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public protocols are viewable by everyone" 
    ON protocols FOR SELECT 
    USING (is_public = true);

CREATE POLICY "Authors can view their own protocols" 
    ON protocols FOR SELECT 
    USING (author_id::text = current_setting('request.jwt.claims', true)::json->>'sub');

CREATE POLICY "Authors can manage their own protocols" 
    ON protocols FOR ALL 
    USING (author_id::text = current_setting('request.jwt.claims', true)::json->>'sub');

-- 6. EXPERIMENTS
-- Execution of experiments
CREATE TABLE IF NOT EXISTS experiments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    protocol_id UUID REFERENCES protocols(id) ON DELETE SET NULL,
    status TEXT CHECK (status IN ('planned', 'in_progress', 'completed', 'failed')) DEFAULT 'planned',
    notes TEXT,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Experiments
ALTER TABLE experiments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own experiments" 
    ON experiments FOR SELECT 
    USING (user_id::text = current_setting('request.jwt.claims', true)::json->>'sub');

CREATE POLICY "Users can manage their own experiments" 
    ON experiments FOR ALL 
    USING (user_id::text = current_setting('request.jwt.claims', true)::json->>'sub');

-- 7. DATA ENTRIES
-- Data points linked to experiments
CREATE TABLE IF NOT EXISTS data_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_id UUID REFERENCES experiments(id) ON DELETE CASCADE,
    data_type TEXT, -- 'image', 'csv', 'note'
    data_payload JSONB,
    file_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Data Entries
ALTER TABLE data_entries ENABLE ROW LEVEL SECURITY;

-- Logic: If you can view the experiment, you can view the data.
-- Since experiments are private to the user (currently), this inherits that privacy.
CREATE POLICY "Users can view data for their experiments" 
    ON data_entries FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM experiments
            WHERE experiments.id = data_entries.experiment_id
            AND experiments.user_id::text = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can manage data for their experiments" 
    ON data_entries FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM experiments
            WHERE experiments.id = data_entries.experiment_id
            AND experiments.user_id::text = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

-- 8. TEAM NOTES
-- General collaboration notes
CREATE TABLE IF NOT EXISTS team_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT,
    tags TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for Team Notes
ALTER TABLE team_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Team notes are viewable by everyone" 
    ON team_notes FOR SELECT 
    USING (true);

CREATE POLICY "Authors can manage their own notes" 
    ON team_notes FOR ALL 
    USING (author_id::text = current_setting('request.jwt.claims', true)::json->>'sub');
