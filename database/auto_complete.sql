-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — sweep stale games
-- Run AFTER schema.sql + notifications.sql. Idempotent: safe to re-run.
--
-- Two things happen here, both triggered by kick-off time passing:
--   1. A matched game still unscored 4 hours after kick-off is finalised as a
--      0–0 draw (1 league point each) and moves to "Finished".
--   2. An OPEN game whose kick-off has passed with no opponent picked (nobody
--      joined) is deleted — its bids go with it (FK cascade).
--
-- How it runs:
--   • pg_cron, every 15 min (auto-scheduled below if the extension is enabled).
--   • The app calls public.auto_complete_stale_games() when the feed / My Games
--     load, so it works even on projects without pg_cron.
-- ════════════════════════════════════════════════════════════════════════════

create or replace function public.auto_complete_stale_games()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
  n integer := 0;
  opp_captain uuid;
begin
  -- ── 1. Auto-finish matched-but-unscored games as 0–0 after 4 hours ─────────
  for r in
    with updated as (
      update public.games g
         set status     = 'completed',
             host_score = 0,
             opp_score  = 0,
             scored_at  = now()
       where g.status = 'matched'
         and g.host_score is null
         and g.kickoff < now() - interval '4 hours'
      returning g.id, g.host_captain_id, g.opponent_team_id
    )
    select * from updated
  loop
    n := n + 1;
    perform public.notify_user(
      r.host_captain_id, 'result_auto', 'Game auto-finished',
      'No score was entered in time, so it was recorded as 0–0.',
      jsonb_build_object('game_id', r.id));

    if r.opponent_team_id is not null then
      select captain_id into opp_captain
        from public.teams where id = r.opponent_team_id;
      if opp_captain is not null then
        perform public.notify_user(
          opp_captain, 'result_auto', 'Game auto-finished',
          'No score was entered in time, so it was recorded as 0–0.',
          jsonb_build_object('game_id', r.id));
      end if;
    end if;
  end loop;

  -- ── 2. Delete open games nobody joined once kick-off has passed ────────────
  -- Tell the host their game expired.
  for r in
    select id, host_captain_id from public.games
     where status = 'open' and kickoff < now()
  loop
    perform public.notify_user(
      r.host_captain_id, 'game_expired', 'Game expired',
      'No team was picked before kick-off, so your game was removed.',
      jsonb_build_object('game_id', r.id));
  end loop;

  -- Tell anyone who had requested to play that the game is gone.
  for r in
    select b.bidder_user_id, b.game_id
      from public.bids b
      join public.games g on g.id = b.game_id
     where g.status = 'open' and g.kickoff < now()
  loop
    perform public.notify_user(
      r.bidder_user_id, 'game_removed', 'Game removed',
      'A game you requested was removed because the host didn''t pick a team in time.',
      jsonb_build_object('game_id', r.game_id));
  end loop;

  -- Remove them (bids cascade-delete via the FK).
  delete from public.games
   where status = 'open' and kickoff < now();

  return n;
end;
$$;

grant execute on function public.auto_complete_stale_games() to authenticated;

-- ── Optional: schedule it with pg_cron (every 15 minutes) ────────────────────
-- Skipped automatically if pg_cron isn't enabled on this project. To enable:
--   Supabase dashboard → Database → Extensions → enable "pg_cron".
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule(
      'auto-complete-stale-games',
      '*/15 * * * *',
      'select public.auto_complete_stale_games();'
    );
  end if;
exception when others then
  -- Never let scheduling failures block the migration.
  null;
end $$;
