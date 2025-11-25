-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. User Profiles Table
create table user_profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  full_name text,
  what_i_love text,
  what_im_good_at text,
  what_the_world_needs text,
  what_i_can_be_paid_for text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Brand Profiles Table
create table brand_profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  selected_profile_name text,
  selected_category text,
  selected_micro_niche text,
  selected_premise text,
  tone_of_voice text,
  target_audience text,
  strengths text,
  weaknesses text,
  opportunities text,
  threats text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Content Ideas Table
create table content_ideas (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  pillar text,
  title text,
  angle text,
  content_overview text,
  viral_potential text,
  insight text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS Policies (Row Level Security)
alter table user_profiles enable row level security;
alter table brand_profiles enable row level security;
alter table content_ideas enable row level security;

-- Policy: Users can only see and edit their own data
create policy "Users can view own profile" on user_profiles
  for select using (auth.uid() = user_id);

create policy "Users can insert own profile" on user_profiles
  for insert with check (auth.uid() = user_id);

create policy "Users can update own profile" on user_profiles
  for update using (auth.uid() = user_id);

create policy "Users can view own brand" on brand_profiles
  for select using (auth.uid() = user_id);

create policy "Users can insert own brand" on brand_profiles
  for insert with check (auth.uid() = user_id);

create policy "Users can update own brand" on brand_profiles
  for update using (auth.uid() = user_id);

create policy "Users can view own ideas" on content_ideas
  for select using (auth.uid() = user_id);

create policy "Users can insert own ideas" on content_ideas
  for insert with check (auth.uid() = user_id);
