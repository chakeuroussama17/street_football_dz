-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — admin recognition + ads/announcements
-- Run AFTER schema.sql.
-- ════════════════════════════════════════════════════════════════════════════

-- Admin = the configured admin phone (auth.users.phone is stored WITHOUT the
-- leading '+', so use the digits only), OR any user row flagged role='admin'.
-- Keep this phone in sync with `adminPhone` in supabase_service.dart.
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public, auth as $$
  select coalesce(
           (select phone from auth.users where id = auth.uid()) = '213000000000',
           false)
      or exists (select 1 from public.users
                 where id = auth.uid() and role = 'admin');
$$;

grant execute on function public.is_admin() to authenticated;

-- ── ads / announcements (shown as a banner on the feed) ──────────────────────
create table if not exists public.ads (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  body       text,
  link       text,
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.ads enable row level security;

drop policy if exists ads_select on public.ads;
drop policy if exists ads_write  on public.ads;
-- Everyone signed in can read ads (the app shows only active ones on the feed).
create policy ads_select on public.ads for select to authenticated using (true);
-- Only the admin can create / edit / delete ads.
create policy ads_write on public.ads for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
