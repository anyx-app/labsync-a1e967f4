# Schema Plan: LabSync

## Overview
LabSync requires a robust schema to handle users (researchers, lab managers), equipment booking, maintenance tracking, experiment protocols, and data analysis. We will leverage Supabase (PostgreSQL) features like RLS for security.

## Tables

### 1. `profiles`
- **Purpose**: Stores extended user information linked to `auth.users`.
- **Columns**:
  - `id` (uuid, PK, references `auth.users.id`)
  - `email` (text, not null)
  - `full_name` (text)
  - `role` (text, enum: 'researcher', 'manager', 'admin')
  - `department` (text)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

### 2. `equipment`
- **Purpose**: Inventory of lab equipment available for booking.
- **Columns**:
  - `id` (uuid, PK)
  - `name` (text, not null)
  - `description` (text)
  - `model_number` (text)
  - `serial_number` (text)
  - `status` (text, enum: 'available', 'maintenance', 'retired')
  - `location` (text)
  - `image_url` (text)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

### 3. `bookings`
- **Purpose**: Manages reservations of equipment by users.
- **Columns**:
  - `id` (uuid, PK)
  - `equipment_id` (uuid, FK references `equipment.id`)
  - `user_id` (uuid, FK references `profiles.id`)
  - `start_time` (timestamptz, not null)
  - `end_time` (timestamptz, not null)
  - `purpose` (text)
  - `status` (text, enum: 'confirmed', 'cancelled', 'completed')
  - `created_at` (timestamptz)

### 4. `maintenance_logs`
- **Purpose**: Tracks maintenance history for equipment.
- **Columns**:
  - `id` (uuid, PK)
  - `equipment_id` (uuid, FK references `equipment.id`)
  - `performed_by` (uuid, FK references `profiles.id`)
  - `description` (text, not null)
  - `date_performed` (timestamptz, default now())
  - `next_maintenance_due` (timestamptz)
  - `cost` (numeric)
  - `created_at` (timestamptz)

### 5. `protocols`
- **Purpose**: Stores standard operating procedures and experiment protocols.
- **Columns**:
  - `id` (uuid, PK)
  - `title` (text, not null)
  - `content` (text, markdown/json)
  - `author_id` (uuid, FK references `profiles.id`)
  - `is_public` (boolean, default false) - internal sharing vs private
  - `version` (int, default 1)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

### 6. `experiments`
- **Purpose**: Tracks actual execution of experiments, possibly linking to protocols.
- **Columns**:
  - `id` (uuid, PK)
  - `title` (text, not null)
  - `user_id` (uuid, FK references `profiles.id`)
  - `protocol_id` (uuid, FK references `protocols.id`, nullable)
  - `status` (text, enum: 'planned', 'in_progress', 'completed', 'failed')
  - `notes` (text)
  - `start_date` (timestamptz)
  - `end_date` (timestamptz)
  - `created_at` (timestamptz)

### 7. `data_entries`
- **Purpose**: Stores specific data points or file references collected during experiments.
- **Columns**:
  - `id` (uuid, PK)
  - `experiment_id` (uuid, FK references `experiments.id`)
  - `data_type` (text) - e.g., 'image', 'csv', 'note'
  - `data_payload` (jsonb) - flexible storage for results
  - `file_url` (text, nullable)
  - `created_at` (timestamptz)

### 8. `team_notes`
- **Purpose**: General collaboration notes not tied to specific experiments.
- **Columns**:
  - `id` (uuid, PK)
  - `author_id` (uuid, FK references `profiles.id`)
  - `content` (text)
  - `tags` (text[])
  - `created_at` (timestamptz)

## Security Policies (RLS)
- **Profiles**: Users can view all profiles (for collaboration), update own.
- **Equipment**: Publicly viewable by auth users, editable by Managers/Admins.
- **Bookings**: Users view all (to check availability), create own, edit own. Managers can edit all.
- **Protocols**: Viewable if `is_public` or author is viewer.
- **Experiments/Data**: Private to user unless shared (future feature).

## Relationships
- Users -> Bookings (1:N)
- Equipment -> Bookings (1:N)
- Equipment -> MaintenanceLogs (1:N)
- Users -> Protocols (1:N)
- Users -> Experiments (1:N)
- Protocols -> Experiments (1:N)
- Experiments -> DataEntries (1:N)
