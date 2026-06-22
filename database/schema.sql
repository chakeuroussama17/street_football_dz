-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — core schema
-- Run this in the Supabase SQL editor on a NEW, EMPTY project.
-- Idempotent: safe to re-run.
-- ════════════════════════════════════════════════════════════════════════════

create extension if not exists "pgcrypto";

-- ── users ────────────────────────────────────────────────────────────────────
-- One row per registered person. id = auth.users.id. Phone is the login + a
-- visible contact field. Each user belongs to exactly one team (a captain owns
-- it; a player joined it by code).
create table if not exists public.users (
  id            uuid primary key references auth.users(id) on delete cascade,
  phone         text unique,
  full_name     text not null default '',
  date_of_birth date,
  city          text,                                   -- wilaya (Latin name)
  role          text not null default 'player'
                  check (role in ('player','captain','admin')),
  team_id       uuid,                                   -- FK added below
  avatar_url    text,
  is_banned     boolean not null default false,
  created_at    timestamptz not null default now()
);

-- ── teams ────────────────────────────────────────────────────────────────────
create table if not exists public.teams (
  id          uuid primary key default gen_random_uuid(),
  captain_id  uuid not null references public.users(id) on delete cascade,
  name        text not null,
  logo_url    text,
  city        text,
  age_min     int,
  age_max     int,
  details     text,
  team_code   text not null unique,                     -- short join code
  created_at  timestamptz not null default now()
);

-- users.team_id → teams.id (added after teams exists).
do $$ begin
  alter table public.users
    add constraint users_team_fk foreign key (team_id)
    references public.teams(id) on delete set null;
exception when duplicate_object then null; end $$;

-- ── games (posts) ────────────────────────────────────────────────────────────
create table if not exists public.games (
  id               uuid primary key default gen_random_uuid(),
  host_team_id     uuid not null references public.teams(id) on delete cascade,
  host_captain_id  uuid not null references public.users(id) on delete cascade,
  format           text not null check (format in ('5','7','9','11')),
  city             text,
  field_address    text,
  kickoff          timestamptz not null,
  duration_minutes int not null default 90,
  photo_url        text,
  details          text,
  status           text not null default 'open'
                     check (status in ('open','matched','completed','cancelled')),
  opponent_team_id uuid references public.teams(id) on delete set null,
  accepted_bid_id  uuid,
  host_score       int,
  opp_score        int,
  scored_at        timestamptz,
  created_at       timestamptz not null default now()
);

-- ── bids (a team applies to play a posted game) ──────────────────────────────
create table if not exists public.bids (
  id             uuid primary key default gen_random_uuid(),
  game_id        uuid not null references public.games(id) on delete cascade,
  bidder_team_id uuid not null references public.teams(id) on delete cascade,
  bidder_user_id uuid not null references public.users(id) on delete cascade,
  message        text,
  phone          text,
  status         text not null default 'pending'
                   check (status in ('pending','accepted','rejected')),
  created_at     timestamptz not null default now(),
  unique (game_id, bidder_team_id)
);

-- ── ratings (visiting team rates the host team after the game) ────────────────
create table if not exists public.ratings (
  id            uuid primary key default gen_random_uuid(),
  game_id       uuid not null references public.games(id) on delete cascade,
  rater_team_id uuid not null references public.teams(id) on delete cascade,
  rated_team_id uuid not null references public.teams(id) on delete cascade,
  stars         int not null check (stars between 1 and 5),
  created_at    timestamptz not null default now(),
  unique (game_id, rater_team_id)
);

-- ── indexes ──────────────────────────────────────────────────────────────────
create index if not exists idx_games_status_kickoff on public.games(status, kickoff);
create index if not exists idx_games_city on public.games(city);
create index if not exists idx_games_opponent on public.games(opponent_team_id);
create index if not exists idx_bids_game on public.bids(game_id);
create index if not exists idx_users_team on public.users(team_id);

-- ── helper functions (SECURITY DEFINER, bypass RLS for ownership checks) ──────
create or replace function public.my_team_id()
returns uuid language sql stable security definer set search_path = public as $$
  select team_id from public.users where id = auth.uid();
$$;

create or replace function public.is_team_captain(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.teams where id = t and captain_id = auth.uid());
$$;

create or replace function public.is_game_host(g uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.games where id = g and host_captain_id = auth.uid());
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- Row Level Security
-- ════════════════════════════════════════════════════════════════════════════
alter table public.users   enable row level security;
alter table public.teams   enable row level security;
alter table public.games   enable row level security;
alter table public.bids    enable row level security;
alter table public.ratings enable row level security;

-- users: profiles publicly readable; you manage only your own row.
drop policy if exists users_select       on public.users;
drop policy if exists users_insert_self  on public.users;
drop policy if exists users_update_self  on public.users;
create policy users_select      on public.users for select to authenticated using (true);
create policy users_insert_self on public.users for insert to authenticated with check (id = auth.uid());
create policy users_update_self on public.users for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- teams: public league; the captain manages their own team.
drop policy if exists teams_select on public.teams;
drop policy if exists teams_insert on public.teams;
drop policy if exists teams_update on public.teams;
drop policy if exists teams_delete on public.teams;
create policy teams_select on public.teams for select to authenticated using (true);
create policy teams_insert on public.teams for insert to authenticated with check (captain_id = auth.uid());
create policy teams_update on public.teams for update to authenticated using (captain_id = auth.uid()) with check (captain_id = auth.uid());
create policy teams_delete on public.teams for delete to authenticated using (captain_id = auth.uid());

-- games: public feed; the host captain manages their own posts.
drop policy if exists games_select on public.games;
drop policy if exists games_insert on public.games;
drop policy if exists games_update on public.games;
drop policy if exists games_delete on public.games;
create policy games_select on public.games for select to authenticated using (true);
create policy games_insert on public.games for insert to authenticated
  with check (host_captain_id = auth.uid() and public.is_team_captain(host_team_id));
create policy games_update on public.games for update to authenticated
  using (host_captain_id = auth.uid()) with check (host_captain_id = auth.uid());
create policy games_delete on public.games for delete to authenticated using (host_captain_id = auth.uid());

-- bids: visible to the game host and the bidder; you bid for your own team;
-- the host accepts/rejects (updates status).
drop policy if exists bids_select on public.bids;
drop policy if exists bids_insert on public.bids;
drop policy if exists bids_update on public.bids;
drop policy if exists bids_delete on public.bids;
create policy bids_select on public.bids for select to authenticated
  using (bidder_user_id = auth.uid() or public.is_game_host(game_id));
create policy bids_insert on public.bids for insert to authenticated
  with check (bidder_user_id = auth.uid() and bidder_team_id = public.my_team_id());
create policy bids_update on public.bids for update to authenticated
  using (public.is_game_host(game_id)) with check (public.is_game_host(game_id));
create policy bids_delete on public.bids for delete to authenticated using (bidder_user_id = auth.uid());

-- ratings: public read; you rate as your own (visiting) team.
drop policy if exists ratings_select on public.ratings;
drop policy if exists ratings_insert on public.ratings;
create policy ratings_select on public.ratings for select to authenticated using (true);
create policy ratings_insert on public.ratings for insert to authenticated
  with check (rater_team_id = public.my_team_id());

-- ════════════════════════════════════════════════════════════════════════════
-- League standings view (the "Algerian League"). Points: win 3 / draw 1 / loss 0
-- (no goal counting). New teams appear automatically at 0 pts.
-- ════════════════════════════════════════════════════════════════════════════
create or replace view public.team_standings as
with results as (
  select host_team_id as team_id,
         case when host_score > opp_score then 3
              when host_score = opp_score then 1 else 0 end as pts,
         (host_score > opp_score)::int as win,
         (host_score = opp_score)::int as draw,
         (host_score < opp_score)::int as loss
  from public.games
  where status = 'completed' and host_score is not null and opp_score is not null
  union all
  select opponent_team_id as team_id,
         case when opp_score > host_score then 3
              when opp_score = host_score then 1 else 0 end as pts,
         (opp_score > host_score)::int as win,
         (opp_score = host_score)::int as draw,
         (opp_score < host_score)::int as loss
  from public.games
  where status = 'completed' and host_score is not null and opp_score is not null
    and opponent_team_id is not null
),
agg as (
  select t.id as team_id,
         coalesce(sum(r.pts),0)  as points,
         coalesce(sum(r.win),0)  as wins,
         coalesce(sum(r.draw),0) as draws,
         coalesce(sum(r.loss),0) as losses,
         count(r.team_id)        as played
  from public.teams t
  left join results r on r.team_id = t.id
  group by t.id
),
rt as (
  select rated_team_id as team_id,
         round(avg(stars)::numeric, 2) as rating_avg,
         count(*) as rating_count
  from public.ratings group by rated_team_id
)
select t.id, t.name, t.logo_url, t.city, t.captain_id,
       t.age_min, t.age_max,
       a.points, a.wins, a.draws, a.losses, a.played,
       coalesce(rt.rating_avg, 0) as rating_avg,
       coalesce(rt.rating_count, 0) as rating_count,
       rank() over (order by a.points desc,
                             coalesce(rt.rating_avg,0) desc,
                             a.wins desc) as rank
from public.teams t
join agg a on a.team_id = t.id
left join rt on rt.team_id = t.id;

grant select on public.team_standings to authenticated;

-- ── realtime (live feed + bids) ──────────────────────────────────────────────
do $$ begin
  alter publication supabase_realtime add table public.games;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.bids;
exception when duplicate_object then null; end $$;
