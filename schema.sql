-- Wachpolizei Dienstwagen App – Supabase Schema
-- Einmalig im SQL Editor ausführen

-- Benutzer
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  name text not null,
  gruppe text not null,
  role text not null default 'user', -- 'admin' | 'user'
  password_hash text not null,
  created_at timestamptz default now()
);

-- Einladungen
create table if not exists public.invites (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  code text unique not null,
  used boolean default false,
  created_at timestamptz default now()
);

-- Wochendaten pro Fahrzeug
create table if not exists public.week_data (
  id uuid primary key default gen_random_uuid(),
  week_key text not null,        -- z.B. "KW23-2025"
  kennzeichen text not null,
  status text not null default 'free', -- 'free' | 'active' | 'locked'
  inspector_id uuid references public.users(id) on delete set null,
  inspector_name text,
  inspector_gruppe text,
  checklist jsonb default '{}',
  notes jsonb default '{}',
  cleaning_innen text default '',
  cleaning_aussen text default '',
  maengel text default '',
  completed_at text default '',
  updated_at timestamptz default now(),
  unique(week_key, kennzeichen)
);

-- RLS (Row Level Security) – alle authentifizierten Zugriffe erlauben
-- (wir nutzen eigenes Auth-System, daher anon key mit vollen Rechten)
alter table public.users enable row level security;
alter table public.invites enable row level security;
alter table public.week_data enable row level security;

create policy "allow all users" on public.users for all using (true) with check (true);
create policy "allow all invites" on public.invites for all using (true) with check (true);
create policy "allow all week_data" on public.week_data for all using (true) with check (true);

