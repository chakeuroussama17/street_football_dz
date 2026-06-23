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
  image_url  text,
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

-- For projects created before image_url existed.
alter table public.ads add column if not exists image_url text;

alter table public.ads enable row level security;

drop policy if exists ads_select on public.ads;
drop policy if exists ads_write  on public.ads;
-- Everyone signed in can read ads (the app shows only active ones on the feed).
create policy ads_select on public.ads for select to authenticated using (true);
-- Only the admin can create / edit / delete ads.
create policy ads_write on public.ads for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ── ad image storage (public bucket; writes locked to the uploader's folder) ──
insert into storage.buckets (id, name, public)
values ('ad-images', 'ad-images', true)
on conflict (id) do nothing;

drop policy if exists ad_images_read on storage.objects;
create policy ad_images_read on storage.objects for select to public
  using (bucket_id = 'ad-images');

drop policy if exists ad_images_write on storage.objects;
create policy ad_images_write on storage.objects for insert to authenticated
  with check (bucket_id = 'ad-images'
              and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists ad_images_update on storage.objects;
create policy ad_images_update on storage.objects for update to authenticated
  using (bucket_id = 'ad-images'
         and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists ad_images_delete on storage.objects;
create policy ad_images_delete on storage.objects for delete to authenticated
  using (bucket_id = 'ad-images'
         and (storage.foldername(name))[1] = auth.uid()::text);
