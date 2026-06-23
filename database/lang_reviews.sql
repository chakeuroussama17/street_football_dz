-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — per-user language + review comments
-- Run AFTER schema.sql. Idempotent.
-- ════════════════════════════════════════════════════════════════════════════

-- Each user remembers their preferred UI language (Arabic by default).
alter table public.users add column if not exists language text not null default 'ar';

-- Visiting captains can leave a short written review with their rating.
alter table public.ratings add column if not exists comment text;
