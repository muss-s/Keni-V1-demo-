-- Auto cover: when an admin approves a place photo and the place has no cover, that photo becomes the cover.
-- Undo clears it again, but only if the cover is still that photo.
create or replace function public.menu_photo_review(p_id bigint, p_ok boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare m public.menu_photos; pname text; cover boolean := false;
  u text;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.menu_photos set status = case when p_ok then 'approved' else 'rejected' end, reviewed_at = now(), reviewed_by = auth.uid()
    where id = p_id and status = 'pending' returning * into m;
  if not found then raise exception 'not waiting'; end if;
  u := 'https://wlxkdivnktxdbwbertjw.supabase.co/storage/v1/object/public/menu-photos/' || m.path;
  if p_ok and m.kind = 'place' then
    update public.places set photo = u where id = m.place_id and coalesce(photo, '') = '';
    cover := found;
  end if;
  select name into pname from public.places where id = m.place_id;
  perform public.notify(m.user_id, case when p_ok then 'menu_ok' else 'menu_no' end, null, jsonb_build_object('place', m.place_id, 'name', pname, 'kind', m.kind, 'cover', cover));
  perform public.push_enqueue_user(m.user_id, coalesce(pname, 'Keni'),
    case when p_ok then 'Your ' || case when m.kind = 'place' then 'photo' else 'menu photo' end || ' is up' || case when cover then ' as the cover photo' else '' end || '. Thanks for helping!'
      else 'Your ' || case when m.kind = 'place' then 'photo' else 'menu photo' end || ' wasn’t added this time.' end, 'menu-' || m.id, '/#activity');
  return jsonb_build_object('id', m.id, 'status', m.status, 'path', m.path, 'cover', cover);
end $$;

create or replace function public.menu_photo_unreview(p_id bigint)
returns text language plpgsql security definer set search_path = '' as $$
declare m public.menu_photos;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  select * into m from public.menu_photos where id = p_id;
  if not found then raise exception 'not found'; end if;
  update public.places set photo = null where id = m.place_id
    and photo = 'https://wlxkdivnktxdbwbertjw.supabase.co/storage/v1/object/public/menu-photos/' || m.path;
  update public.menu_photos set status = 'pending', reviewed_at = null, reviewed_by = null where id = p_id;
  delete from public.notifications where kind in ('menu_ok', 'menu_no') and created_at > now() - interval '10 minutes'
    and user_id = m.user_id and data ->> 'place' = m.place_id;
  return 'ok';
end $$;
notify pgrst, 'reload schema';
