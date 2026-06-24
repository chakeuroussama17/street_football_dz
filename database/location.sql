-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — map location for games
-- Run AFTER schema.sql. Idempotent: safe to re-run.
--
-- Adds the precise coordinates chosen on the map picker. `field_address` keeps
-- the reverse-geocoded address string; lat/lng let teams open the exact spot in
-- Google/Apple Maps.
-- ════════════════════════════════════════════════════════════════════════════

alter table public.games add column if not exists lat double precision;
alter table public.games add column if not exists lng double precision;
