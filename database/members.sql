-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — multi-team membership
-- Run AFTER schema.sql. Idempotent: safe to re-run.
--
-- A player can belong to MANY teams (join any team whose code they have). The
-- roster is now driven by this join table instead of users.team_id. We keep
-- users.team_id as the user's *active* team (the one they currently act as for
-- posting / bidding / My Games). The team captain can remove any member.
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.team_members (
  team_id   uuid not null references public.teams(id) on delete cascade,
  user_id   uuid not null references public.users(id) on delete cascade,
  role      text not null default 'player' check (role in ('captain','player')),
  joined_at timestamptz not null default now(),
  primary key (team_id, user_id)
);

create index if not exists idx_team_members_user on public.team_members(user_id);
create index if not exists idx_team_members_team on public.team_members(team_id);

-- ── Backfill from the old single-team model ─────────────────────────────────
-- Every captain is a member of the team they own…
insert into public.team_members (team_id, user_id, role)
  select t.id, t.captain_id, 'captain' from public.teams t
on conflict do nothing;
-- …and every user's current team_id becomes a membership.
insert into public.team_members (team_id, user_id, role)
  select u.team_id, u.id,
         case when t.captain_id = u.id then 'captain' else 'player' end
    from public.users u
    join public.teams t on t.id = u.team_id
   where u.team_id is not null
on conflict do nothing;

-- ── helpers ─────────────────────────────────────────────────────────────────
create or replace function public.is_team_member(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from public.team_members
     where team_id = t and user_id = auth.uid());
$$;

-- Captain removes a member (and clears their active pointer if it was this team).
-- SECURITY DEFINER so it can touch the removed user's row; guarded to captains.
create or replace function public.remove_team_member(p_team uuid, p_user uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.is_team_captain(p_team) then
    raise exception 'Only the captain can remove members';
  end if;
  if exists (select 1 from public.teams where id = p_team and captain_id = p_user) then
    raise exception 'The captain cannot be removed';
  end if;
  delete from public.team_members where team_id = p_team and user_id = p_user;
  update public.users set team_id = null
    where id = p_user and team_id = p_team;
end;
$$;

grant execute on function public.is_team_member(uuid)            to authenticated;
grant execute on function public.remove_team_member(uuid, uuid)  to authenticated;

-- ── RLS ─────────────────────────────────────────────────────────────────────
alter table public.team_members enable row level security;

drop policy if exists tm_select      on public.team_members;
drop policy if exists tm_insert_self on public.team_members;
drop policy if exists tm_delete_self on public.team_members;

-- Rosters are public (like the teams/league).
create policy tm_select on public.team_members for select to authenticated using (true);
-- You add yourself to a team (the app first verified the join code).
create policy tm_insert_self on public.team_members for insert to authenticated
  with check (user_id = auth.uid());
-- You can leave a team yourself; captain removal goes through remove_team_member().
create policy tm_delete_self on public.team_members for delete to authenticated
  using (user_id = auth.uid());

-- ── A team member (any of their teams) may bid as that team ─────────────────
drop policy if exists bids_insert on public.bids;
create policy bids_insert on public.bids for insert to authenticated
  with check (bidder_user_id = auth.uid()
              and public.is_team_member(bidder_team_id));

-- Realtime so rosters update live.
do $$ begin
  alter publication supabase_realtime add table public.team_members;
exception when duplicate_object then null; end $$;
