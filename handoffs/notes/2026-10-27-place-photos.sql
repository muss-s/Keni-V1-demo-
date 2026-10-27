-- Place photos from people: same table, bucket and review as menu photos, with a kind ('menu' or 'place').
alter table public.menu_photos add column if not exists kind text not null default 'menu' check (kind in ('menu', 'place'));
drop index if exists public.menu_photos_place;
create index if not exists menu_photos_place on public.menu_photos (place_id, kind, status);

drop function if exists public.menu_photo_add(text, text, int, int);
create function public.menu_photo_add(p_place text, p_path text, p_w int, p_h int, p_kind text default 'menu')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.menu_photos;
begin
  if me is null then raise exception 'sign in'; end if;
  if coalesce(p_kind, 'menu') not in ('menu', 'place') then raise exception 'bad kind'; end if;
  if split_part(p_path, '/', 1) <> me::text then raise exception 'bad path'; end if;
  if not exists (select 1 from public.places where id = p_place) then raise exception 'no such place'; end if;
  if (select count(*) from public.menu_photos where user_id = me and status = 'pending') >= 10 then raise exception 'too many waiting'; end if;
  insert into public.menu_photos (place_id, user_id, path, w, h, kind) values (p_place, me, p_path, p_w, p_h, coalesce(p_kind, 'menu')) returning * into r;
  return jsonb_build_object('id', r.id, 'path', r.path, 'status', r.status, 'at', r.created_at, 'kind', r.kind);
end $$;

drop function if exists public.menu_photos_for(text);
create function public.menu_photos_for(p_place text, p_kind text default 'menu')
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', m.id, 'path', m.path, 'w', m.w, 'h', m.h, 'status', m.status, 'at', m.created_at, 'kind', m.kind,
      'mine', m.user_id = auth.uid(), 'by', coalesce(nullif(split_part(trim(p.name), ' ', 1), ''), 'Someone'))
    order by (m.status = 'approved') desc, m.created_at desc), '[]')
  from public.menu_photos m left join public.profiles p on p.id = m.user_id
  where m.place_id = p_place and m.kind = coalesce(p_kind, 'menu') and (m.status = 'approved' or (m.status = 'pending' and m.user_id = auth.uid())) $$;

create or replace function public.menu_photo_pending()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', m.id, 'path', m.path, 'w', m.w, 'h', m.h, 'at', m.created_at, 'place_id', m.place_id, 'place', pl.name, 'kind', m.kind,
      'user', m.user_id, 'by', coalesce(p.name, 'Someone'), 'approved_here', (select count(*) from public.menu_photos x where x.place_id = m.place_id and x.kind = m.kind and x.status = 'approved'))
    order by m.created_at) from public.menu_photos m join public.places pl on pl.id = m.place_id left join public.profiles p on p.id = m.user_id
    where m.status = 'pending'), '[]');
end $$;

create or replace function public.menu_photo_review(p_id bigint, p_ok boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare m public.menu_photos; pname text;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.menu_photos set status = case when p_ok then 'approved' else 'rejected' end, reviewed_at = now(), reviewed_by = auth.uid()
    where id = p_id and status = 'pending' returning * into m;
  if not found then raise exception 'not waiting'; end if;
  select name into pname from public.places where id = m.place_id;
  perform public.notify(m.user_id, case when p_ok then 'menu_ok' else 'menu_no' end, null, jsonb_build_object('place', m.place_id, 'name', pname, 'kind', m.kind));
  perform public.push_enqueue_user(m.user_id, coalesce(pname, 'Keni'),
    case when p_ok then 'Your ' || case when m.kind = 'place' then 'photo' else 'menu photo' end || ' is up. Thanks for helping!'
      else 'Your ' || case when m.kind = 'place' then 'photo' else 'menu photo' end || ' wasn’t added this time.' end, 'menu-' || m.id, null);
  return jsonb_build_object('id', m.id, 'status', m.status, 'path', m.path);
end $$;

revoke all on function public.menu_photo_add(text, text, int, int, text), public.menu_photos_for(text, text) from public, anon, authenticated;
grant execute on function public.menu_photos_for(text, text) to anon, authenticated;
grant execute on function public.menu_photo_add(text, text, int, int, text) to authenticated;
notify pgrst, 'reload schema';
