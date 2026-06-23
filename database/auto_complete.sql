-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — auto-finish stale games
-- Run AFTER schema.sql + notifications.sql. Idempotent: safe to re-run.
--
-- If the host never records a score, the game is finalised as a 0–0 draw 4 hours
-- after kick-off (both teams get 1 league point) and moves to "Finished".
-- Two ways it runs:
--   1. pg_cron, every 15 min (auto-scheduled below if the extension is enabled).
--   2. The app calls public.auto_complete_stale_games() whenever My Games loads,
--      so it works even on projects without pg_cron.
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

    -- Notify the host captain.
    perform public.notify_user(
      r.host_captain_id,
      'result_auto',
      'Game auto-finished',
      'No score was entered in time, so it was recorded as 0–0.',
      jsonb_build_object('game_id', r.id)
    );

    -- Notify the opponent's captain (if the team still exists).
    if r.opponent_team_id is not null then
      select captain_id into opp_captain
        from public.teams where id = r.opponent_team_id;
      if opp_captain is not null then
        perform public.notify_user(
          opp_captain,
          'result_auto',
          'Game auto-finished',
          'No score was entered in time, so it was recorded as 0–0.',
          jsonb_build_object('game_id', r.id)
        );
      end if;
    end if;
  end loop;

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
