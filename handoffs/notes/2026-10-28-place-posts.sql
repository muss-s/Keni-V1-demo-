-- Keni · promos and events from owners (2026-10-28). Owners (approved place_claims) post a promo or an event for their place.
-- Everyone sees live ones (posts_live). Up to 3 live per place; they stop showing after their end date by themselves.
-- Anyone can report one (post_report); admins take one down (post_takedown) and can undo (post_restore).

create table public.place_posts (
  id bigint generated always as identity primary key,
  place_id text not null references public.places(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('promo', 'event')),
  title text not null check (char_length(title) between 3 and 60),
  details text check (char_length(details) <= 300),
  photo text,
  starts date not null,
  ends date not null,
  at_time numeric check (at_time is null or (at_time >= 0 and at_time <= 23.5)),
  price_txt text check (char_length(price_txt) <= 30),
  days smallint[] check (days is null or (days <@ array[0,1,2,3,4,5,6]::smallint[] and cardinality(days) between 1 and 6)),
  status text not null default 'live' check (status in ('live', 'ended', 'down')),
  down_reason text check (char_length(down_reason) <= 200),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends >= starts and ends <= starts + 92)
);
create index place_posts_live on public.place_posts (ends) where status = 'live';
create index place_posts_place on public.place_posts (place_id);
alter table public.place_posts enable row level security;
revoke all on public.place_posts from anon, authenticated;
comment on table public.place_posts is 'Promos and events owners post for their place. Read and changed only through the post_* and posts_* functions.';

create table public.place_post_reports (
  post_id bigint not null references public.place_posts(id) on delete cascade,
  device text not null check (device ~ '^[0-9a-f]{32}$'),
  user_id uuid,
  created_at timestamptz not null default now(),
  primary key (post_id, device)
);
alter table public.place_post_reports enable row level security;
revoke all on public.place_post_reports from anon, authenticated;

create or replace function public.mnl_today() returns date language sql stable set search_path = '' as $$ select (now() at time zone 'Asia/Manila')::date $$;

-- what everyone sees: live posts that haven't ended and start within two weeks
create or replace function public.posts_live()
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', p.id, 'place', p.place_id, 'kind', p.kind, 'title', p.title, 'details', p.details, 'photo', p.photo,
    'starts', p.starts, 'ends', p.ends, 'time', p.at_time, 'price', p.price_txt, 'days', p.days) order by p.starts, p.id), '[]')
  from public.place_posts p where p.status = 'live' and p.ends >= public.mnl_today() and p.starts <= public.mnl_today() + 14 $$;

-- an owner adds (p_id null) or changes a post
create or replace function public.post_save(p_id bigint, p_place text, p jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.place_posts; today date := public.mnl_today();
  pfx text := 'https://wlxkdivnktxdbwbertjw.supabase.co/storage/v1/object/public/place-photos/';
  v_kind text := p->>'kind'; v_title text := btrim(coalesce(p->>'title', '')); v_det text := nullif(btrim(coalesce(p->>'details', '')), '');
  v_photo text := nullif(p->>'photo', ''); v_start date; v_end date; v_time numeric; v_price text := nullif(btrim(coalesce(p->>'price', '')), ''); v_days smallint[];
begin
  if me is null then raise exception 'sign in'; end if;
  if not public.is_place_owner(p_place) then raise exception 'not yours'; end if;
  if v_kind is null or v_kind not in ('promo', 'event') then raise exception 'kind'; end if;
  if char_length(v_title) < 3 or char_length(v_title) > 60 or v_title ~ '[<>]' then raise exception 'title'; end if;
  if v_det is not null and (char_length(v_det) > 300 or v_det ~ '[<>]') then raise exception 'details'; end if;
  if v_price is not null and (char_length(v_price) > 30 or v_price ~ '[<>]') then raise exception 'price'; end if;
  begin v_start := (p->>'starts')::date; v_end := (p->>'ends')::date; exception when others then raise exception 'dates'; end;
  if v_start is null or v_end is null or v_end < v_start or v_end > v_start + 92 or v_end < today or v_start > today + 60 then raise exception 'dates'; end if;
  if jsonb_typeof(p->'time') = 'number' then v_time := (p->>'time')::numeric; if v_time < 0 or v_time > 23.5 then raise exception 'time'; end if; end if;
  if v_kind = 'event' and v_time is null then raise exception 'time'; end if;
  if jsonb_typeof(p->'days') = 'array' and jsonb_array_length(p->'days') between 1 and 6 then
    begin
      select array_agg(distinct (x::text)::smallint order by (x::text)::smallint) into v_days from jsonb_array_elements(p->'days') x;
    exception when others then raise exception 'days'; end;
    if not v_days <@ array[0,1,2,3,4,5,6]::smallint[] then raise exception 'days'; end if;
  end if;
  if v_kind = 'event' then v_days := null; end if;
  if p_id is not null then
    select * into r from public.place_posts where id = p_id and place_id = p_place and status <> 'down' for update;
    if not found then raise exception 'no such post'; end if;
  end if;
  -- photo: none, the one it already has, or one this person uploaded to their own folder
  if v_photo is not null and v_photo is distinct from r.photo and v_photo !~ ('^' || replace(pfx, '.', '\.') || me::text || '/[0-9a-f]{24}\.jpg$') then raise exception 'photo'; end if;
  if (select count(*) from public.place_posts where place_id = p_place and status = 'live' and ends >= today and id is distinct from p_id) >= 3 then raise exception 'three live'; end if;
  if p_id is null then
    insert into public.place_posts (place_id, user_id, kind, title, details, photo, starts, ends, at_time, price_txt, days)
      values (p_place, me, v_kind, v_title, v_det, v_photo, v_start, v_end, v_time, v_price, v_days) returning * into r;
  else
    update public.place_posts set kind = v_kind, title = v_title, details = v_det, photo = v_photo, starts = v_start, ends = v_end, at_time = v_time,
      price_txt = v_price, days = v_days, status = 'live', updated_at = now() where id = p_id returning * into r;
  end if;
  return jsonb_build_object('id', r.id, 'place', r.place_id, 'kind', r.kind, 'title', r.title, 'details', r.details, 'photo', r.photo,
    'starts', r.starts, 'ends', r.ends, 'time', r.at_time, 'price', r.price_txt, 'days', r.days, 'status', r.status);
end $$;

-- an owner ends a post early
create or replace function public.post_end(p_id bigint)
returns void language plpgsql security definer set search_path = '' as $$
begin
  update public.place_posts set status = 'ended', updated_at = now()
    where id = p_id and status = 'live' and public.is_place_owner(place_id);
  if not found then raise exception 'no such post'; end if;
end $$;

-- an owner's posts for one place (live, plus ended or taken down in the last 30 days)
create or replace function public.posts_mine(p_place text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_place_owner(p_place) then raise exception 'not yours'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', p.id, 'kind', p.kind, 'title', p.title, 'details', p.details, 'photo', p.photo,
      'starts', p.starts, 'ends', p.ends, 'time', p.at_time, 'price', p.price_txt, 'days', p.days, 'status', p.status, 'reason', p.down_reason,
      'over', p.ends < public.mnl_today()) order by (p.status = 'live' and p.ends >= public.mnl_today()) desc, p.starts desc)
    from public.place_posts p where p.place_id = p_place and (p.status = 'live' or p.updated_at > now() - interval '30 days')
      and p.ends >= public.mnl_today() - 30), '[]');
end $$;

-- anyone reports a post as fake or wrong (once per phone)
create or replace function public.post_report(p_id bigint, p_device text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if p_device is null or p_device !~ '^[0-9a-f]{32}$' then raise exception 'device'; end if;
  if not exists (select 1 from public.place_posts where id = p_id and status = 'live') then return; end if;
  insert into public.place_post_reports (post_id, device, user_id) values (p_id, p_device, auth.uid()) on conflict do nothing;
end $$;

-- admins: every live post, with how many reports it has
create or replace function public.posts_admin()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  return coalesce((select jsonb_agg(x order by (x->>'reports')::int desc, x->>'at' desc) from (
    select jsonb_build_object('id', p.id, 'place', p.place_id, 'name', pl.name, 'kind', p.kind, 'title', p.title, 'details', p.details, 'photo', p.photo,
      'starts', p.starts, 'ends', p.ends, 'time', p.at_time, 'price', p.price_txt, 'days', p.days, 'status', p.status, 'reason', p.down_reason, 'at', p.created_at,
      'by', pr.name, 'username', pr.username, 'reports', (select count(*) from public.place_post_reports r where r.post_id = p.id)) x
    from public.place_posts p left join public.places pl on pl.id = p.place_id left join public.profiles pr on pr.id = p.user_id
    where (p.status = 'live' and p.ends >= public.mnl_today()) or (p.status = 'down' and p.updated_at > now() - interval '7 days')) q), '[]');
end $$;

create or replace function public.post_takedown(p_id bigint, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare r public.place_posts; pname text;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.place_posts set status = 'down', down_reason = nullif(btrim(left(coalesce(p_reason, ''), 200)), ''), updated_at = now()
    where id = p_id and status = 'live' returning * into r;
  if not found then raise exception 'not live'; end if;
  select name into pname from public.places where id = r.place_id;
  perform public.notify(r.user_id, 'post_down', null, jsonb_build_object('place', r.place_id, 'name', pname, 'title', r.title, 'reason', r.down_reason));
  perform public.push_enqueue_user(r.user_id, coalesce(pname, 'Keni'),
    'Your ' || r.kind || ' “' || r.title || '” was taken down' || coalesce(': ' || r.down_reason, '') || '.', 'post-' || r.id, '/#studio');
end $$;

create or replace function public.post_restore(p_id bigint)
returns void language plpgsql security definer set search_path = '' as $$
declare r public.place_posts;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.place_posts set status = 'live', down_reason = null, updated_at = now() where id = p_id and status = 'down' returning * into r;
  if not found then raise exception 'not down'; end if;
  delete from public.notifications where kind = 'post_down' and user_id = r.user_id and created_at > now() - interval '10 minutes' and data->>'title' = r.title;
end $$;

revoke all on function public.mnl_today(), public.posts_live(), public.post_save(bigint, text, jsonb), public.post_end(bigint), public.posts_mine(text),
  public.post_report(bigint, text), public.posts_admin(), public.post_takedown(bigint, text), public.post_restore(bigint) from public, anon, authenticated;
grant execute on function public.mnl_today(), public.posts_live(), public.post_report(bigint, text) to anon, authenticated;
grant execute on function public.post_save(bigint, text, jsonb), public.post_end(bigint), public.posts_mine(text),
  public.posts_admin(), public.post_takedown(bigint, text), public.post_restore(bigint) to authenticated;
notify pgrst, 'reload schema';
