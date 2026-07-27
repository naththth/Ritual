-- Ritual: estrutura de dados e segurança para Supabase
-- Execute no Supabase Dashboard > SQL Editor > New query.

create table if not exists public.skin_days (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  payload jsonb not null default '{}'::jsonb,
  finalized_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, log_date)
);

create index if not exists skin_days_user_date_idx
  on public.skin_days (user_id, log_date desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists skin_days_set_updated_at on public.skin_days;
create trigger skin_days_set_updated_at
before update on public.skin_days
for each row execute function public.set_updated_at();

alter table public.skin_days enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.skin_days to authenticated;

-- Cada usuário só vê e altera os próprios registros.
drop policy if exists "skin_days_select_own" on public.skin_days;
create policy "skin_days_select_own"
on public.skin_days for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "skin_days_insert_own" on public.skin_days;
create policy "skin_days_insert_own"
on public.skin_days for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "skin_days_update_own" on public.skin_days;
create policy "skin_days_update_own"
on public.skin_days for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "skin_days_delete_own" on public.skin_days;
create policy "skin_days_delete_own"
on public.skin_days for delete
to authenticated
using ((select auth.uid()) = user_id);

-- Bucket privado para as fotos da pele, limitado a 5 MB por arquivo.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'skin-photos',
  'skin-photos',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- O caminho dos arquivos deverá ser: USER_ID/AAAA-MM-DD/frontal.jpg, etc.
drop policy if exists "skin_photos_select_own" on storage.objects;
create policy "skin_photos_select_own"
on storage.objects for select
to authenticated
using (
  bucket_id = 'skin-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "skin_photos_insert_own" on storage.objects;
create policy "skin_photos_insert_own"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'skin-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "skin_photos_update_own" on storage.objects;
create policy "skin_photos_update_own"
on storage.objects for update
to authenticated
using (
  bucket_id = 'skin-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
)
with check (
  bucket_id = 'skin-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "skin_photos_delete_own" on storage.objects;
create policy "skin_photos_delete_own"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'skin-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);
