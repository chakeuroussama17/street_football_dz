-- ════════════════════════════════════════════════════════════════════════════
-- Street Football DZ — storage buckets + policies
-- Run AFTER schema.sql. Creates two PUBLIC buckets and locks writes to the
-- owner's own folder (folder name = the user's auth uid).
-- ════════════════════════════════════════════════════════════════════════════

insert into storage.buckets (id, name, public)
values ('team-logos', 'team-logos', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('game-photos', 'game-photos', true)
on conflict (id) do nothing;

-- Public read for both buckets.
drop policy if exists sfdz_storage_read on storage.objects;
create policy sfdz_storage_read on storage.objects for select to public
  using (bucket_id in ('team-logos', 'game-photos'));

-- Authenticated users may write only inside their own uid folder.
drop policy if exists sfdz_storage_insert on storage.objects;
create policy sfdz_storage_insert on storage.objects for insert to authenticated
  with check (
    bucket_id in ('team-logos', 'game-photos')
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists sfdz_storage_update on storage.objects;
create policy sfdz_storage_update on storage.objects for update to authenticated
  using (
    bucket_id in ('team-logos', 'game-photos')
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists sfdz_storage_delete on storage.objects;
create policy sfdz_storage_delete on storage.objects for delete to authenticated
  using (
    bucket_id in ('team-logos', 'game-photos')
    and (storage.foldername(name))[1] = auth.uid()::text
  );
