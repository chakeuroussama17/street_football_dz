-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — in-app notifications
-- Run AFTER schema.sql. (FCM push is a later phase; this powers the in-app
-- notifications screen: "your bid was accepted", "new bid on your game", etc.)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.users(id) on delete cascade,
  type       text not null,                 -- 'bid_received' | 'bid_accepted' | ...
  title      text not null,
  body       text,
  data       jsonb,                         -- e.g. {"game_id": "..."}
  read       boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_notifications_user
  on public.notifications(user_id, read, created_at desc);

alter table public.notifications enable row level security;

-- You can only read / mark-read your own notifications.
drop policy if exists notif_select on public.notifications;
drop policy if exists notif_update on public.notifications;
create policy notif_select on public.notifications for select to authenticated
  using (user_id = auth.uid());
create policy notif_update on public.notifications for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Creating a notification for ANOTHER user goes through this SECURITY DEFINER
-- function (so we don't open a blanket insert policy that anyone could abuse).
create or replace function public.notify_user(
  target_user uuid,
  n_type text,
  n_title text,
  n_body text default null,
  n_data jsonb default null
) returns void
language plpgsql security definer set search_path = public as $$
begin
  insert into public.notifications (user_id, type, title, body, data)
  values (target_user, n_type, n_title, n_body, n_data);
end;
$$;

grant execute on function public.notify_user(uuid, text, text, text, jsonb) to authenticated;

-- Realtime so the bell badge updates live.
do $$ begin
  alter publication supabase_realtime add table public.notifications;
exception when duplicate_object then null; end $$;
