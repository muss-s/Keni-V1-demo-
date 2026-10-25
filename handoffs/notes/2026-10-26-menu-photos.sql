-- Menu photos: people add photos of a place's menu, an admin approves them, then everyone sees them in the Menu tab.
-- Files live in the public "menu-photos" bucket under <user id>/<random>.jpg; this table says which are approved.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('menu-photos', 'menu-photos', true, 2097152, array['image/jpeg', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = 2097152, allowed_mime_types = array['image/jpeg', 'image/webp'];

-- upload only into your own folder; delete your own files, or any file if you're an admin
create policy "menu photos: upload to own folder" on storage.objects for insert to authenticated
  with check (bucket_id = 'menu-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "menu photos: delete own or admin" on storage.objects for delete to authenticated
  using (bucket_id = 'menu-photos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

create table if not exists public.menu_photos (
  id bigint generated always as identity primary key,
  place_id text not null references public.places (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  path text not null unique check (path ~ '^[0-9a-f-]{36}/[A-Za-z0-9_-]{8,64}\.(jpg|webp)$'),
  w int check (w between 50 and 4000), h int check (h between 50 and 4000),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz, reviewed_by uuid
);
create index if not exists menu_photos_place on public.menu_photos (place_id, status);
create index if not exists menu_photos_pending on public.menu_photos (created_at) where status = 'pending';
alter table public.menu_photos enable row level security;
-- reading goes through the functions below; no direct table access
revoke all on public.menu_photos from anon, authenticated;

-- add a photo you just uploaded (max 10 waiting per person)
create or replace function public.menu_photo_add(p_place text, p_path text, p_w int, p_h int)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.menu_photos;
begin
  if me is null then raise exception 'sign in'; end if;
  if split_part(p_path, '/', 1) <> me::text then raise exception 'bad path'; end if;
  if not exists (select 1 from public.places where id = p_place) then raise exception 'no such place'; end if;
  if (select count(*) from public.menu_photos where user_id = me and status = 'pending') >= 10 then raise exception 'too many waiting'; end if;
  insert into public.menu_photos (place_id, user_id, path, w, h) values (p_place, me, p_path, p_w, p_h) returning * into r;
  return jsonb_build_object('id', r.id, 'path', r.path, 'status', r.status, 'at', r.created_at);
end $$;

-- the Menu tab: approved photos for everyone, plus your own that are still waiting
create or replace function public.menu_photos_for(p_place text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', m.id, 'path', m.path, 'w', m.w, 'h', m.h, 'status', m.status, 'at', m.created_at,
      'mine', m.user_id = auth.uid(), 'by', coalesce(nullif(split_part(trim(p.name), ' ', 1), ''), 'Someone'))
    order by (m.status = 'approved') desc, m.created_at desc), '[]')
  from public.menu_photos m left join public.profiles p on p.id = m.user_id
  where m.place_id = p_place and (m.status = 'approved' or (m.status = 'pending' and m.user_id = auth.uid())) $$;

-- admin: what's waiting
create or replace function public.menu_photo_pending()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', m.id, 'path', m.path, 'w', m.w, 'h', m.h, 'at', m.created_at, 'place_id', m.place_id, 'place', pl.name,
      'user', m.user_id, 'by', coalesce(p.name, 'Someone'), 'approved_here', (select count(*) from public.menu_photos x where x.place_id = m.place_id and x.status = 'approved'))
    order by m.created_at) from public.menu_photos m join public.places pl on pl.id = m.place_id left join public.profiles p on p.id = m.user_id
    where m.status = 'pending'), '[]');
end $$;

-- admin: approve or reject; the person is told either way (Activity + push)
create or replace function public.menu_photo_review(p_id bigint, p_ok boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare m public.menu_photos; pname text;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.menu_photos set status = case when p_ok then 'approved' else 'rejected' end, reviewed_at = now(), reviewed_by = auth.uid()
    where id = p_id and status = 'pending' returning * into m;
  if not found then raise exception 'not waiting'; end if;
  select name into pname from public.places where id = m.place_id;
  perform public.notify(m.user_id, case when p_ok then 'menu_ok' else 'menu_no' end, null, jsonb_build_object('place', m.place_id, 'name', pname));
  perform public.push_enqueue_user(m.user_id, coalesce(pname, 'Keni'),
    case when p_ok then 'Your menu photo is up. Thanks for helping!' else 'Your menu photo wasn’t added this time.' end, 'menu-' || m.id, null);
  return jsonb_build_object('id', m.id, 'status', m.status, 'path', m.path);
end $$;

-- admin: undo a review (puts it back in the queue)
create or replace function public.menu_photo_unreview(p_id bigint)
returns text language plpgsql security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.menu_photos set status = 'pending', reviewed_at = null, reviewed_by = null where id = p_id;
  delete from public.notifications where kind in ('menu_ok', 'menu_no') and created_at > now() - interval '10 minutes'
    and user_id = (select user_id from public.menu_photos where id = p_id) and data ->> 'place' = (select place_id from public.menu_photos where id = p_id);
  return 'ok';
end $$;

revoke all on function public.menu_photo_add(text, text, int, int), public.menu_photos_for(text), public.menu_photo_pending(),
  public.menu_photo_review(bigint, boolean), public.menu_photo_unreview(bigint) from public, anon, authenticated;
grant execute on function public.menu_photos_for(text) to anon, authenticated;
grant execute on function public.menu_photo_add(text, text, int, int), public.menu_photo_pending(),
  public.menu_photo_review(bigint, boolean), public.menu_photo_unreview(bigint) to authenticated;

-- added after (migration menu_photos_select_own): storage deletes need a select rule too
create policy "menu photos: see own or admin" on storage.objects for select to authenticated
  using (bucket_id = 'menu-photos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));
