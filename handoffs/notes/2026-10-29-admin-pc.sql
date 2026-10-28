-- Keni · PC admin (2026-10-29). Read-only views and a few actions for /admin. Every function checks is_admin() first.
-- Undo: drop the functions below (no tables were added or changed).

-- Overview: the numbers at a glance, plus sign-ups and place views per day for the last 14 days
create or replace function public.admin_overview()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare today date := public.mnl_today();
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  return jsonb_build_object(
    'users', (select count(*) from auth.users),
    'users_new7', (select count(*) from auth.users where created_at > now() - interval '7 days'),
    'active7', (select count(*) from auth.users where last_sign_in_at > now() - interval '7 days'),
    'tropas', (select count(*) from public.tropas),
    'msgs7', (select count(*) from public.tropa_messages where created_at > now() - interval '7 days') + (select count(*) from public.dm_messages where created_at > now() - interval '7 days'),
    'friends', (select count(*) from public.friendships where status = 'accepted'),
    'pasabits_next', (select count(*) from public.pasabits where cancelled_at is null and starts_at > now()),
    'places', (select count(*) from public.places where coalesce(hidden, false) = false and (visibility is null or visibility <> 'tropa')),
    'full', (select count(*) from public.places where level = 'full' and coalesce(hidden, false) = false and (visibility is null or visibility <> 'tropa')),
    'with_hours', (select count(*) from public.places where hours is not null and coalesce(hidden, false) = false),
    'with_photo', (select count(*) from public.places where photo is not null and coalesce(hidden, false) = false),
    'owners', (select count(*) from public.place_claims where status = 'approved'),
    'claims_waiting', (select count(*) from public.place_claims where status = 'pending'),
    'posts_live', (select count(*) from public.place_posts where status = 'live' and ends >= today),
    'views7', (select count(*) from public.place_hits where kind = 'view' and day > today - 7),
    'saves7', (select count(*) from public.place_hits where kind = 'save' and day > today - 7),
    'push', (select count(*) from public.push_subs),
    'days', (select jsonb_agg(jsonb_build_object('day', d::date,
        'signups', (select count(*) from auth.users u where (u.created_at at time zone 'Asia/Manila')::date = d::date),
        'views', (select count(*) from public.place_hits h where h.day = d::date and h.kind = 'view')) order by d)
      from generate_series(today - 13, today, interval '1 day') d));
end $$;

-- Owners: every claim (approved, waiting, rejected), newest first
create or replace function public.owners_admin()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', c.id, 'place', c.place_id, 'name', p.name, 'level', p.level, 'prev', c.prev_level,
      'user', c.user_id, 'by', pr.name, 'username', pr.username, 'email', u.email, 'role', c.role, 'contact', c.contact, 'status', c.status, 'reason', c.reason,
      'at', c.created_at, 'reviewed', c.reviewed_at,
      'posts', (select count(*) from public.place_posts x where x.place_id = c.place_id and x.status = 'live' and x.ends >= public.mnl_today()),
      'views7', (select count(*) from public.place_hits h where h.place_id = c.place_id and h.kind = 'view' and h.day > public.mnl_today() - 7))
      order by (c.status = 'approved') desc, coalesce(c.reviewed_at, c.created_at) desc)
    from public.place_claims c join public.places p on p.id = c.place_id left join public.profiles pr on pr.id = c.user_id left join auth.users u on u.id = c.user_id), '[]');
end $$;

-- Remove an owner: they stop managing the place, a small pin goes back to a small pin, and their live promos end
create or replace function public.owner_remove(p_id bigint)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare c public.place_claims; ended int;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.place_claims set status = 'rejected', reason = 'Removed by the Keni team', reviewed_at = now(), reviewed_by = auth.uid()
    where id = p_id and status = 'approved' returning * into c;
  if not found then raise exception 'not an owner'; end if;
  if c.prev_level = 'basic' and not exists (select 1 from public.place_claims where place_id = c.place_id and status = 'approved') then
    update public.places set level = 'basic' where id = c.place_id;
  end if;
  update public.place_posts set status = 'ended', updated_at = now() where place_id = c.place_id and user_id = c.user_id and status = 'live';
  get diagnostics ended = row_count;
  return jsonb_build_object('id', c.id, 'ended', ended);
end $$;

-- Undo a remove (promos it ended stay ended)
create or replace function public.owner_restore(p_id bigint)
returns void language plpgsql security definer set search_path = '' as $$
declare c public.place_claims;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.place_claims set status = 'approved', reason = null, reviewed_at = now(), reviewed_by = auth.uid()
    where id = p_id and status = 'rejected' and reason = 'Removed by the Keni team' returning * into c;
  if not found then raise exception 'not removed'; end if;
  if c.prev_level = 'basic' then update public.places set level = 'full' where id = c.place_id; end if;
end $$;

-- People: search by name, @username or email (empty = newest 50)
create or replace function public.people_admin(p_q text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare q text := nullif(btrim(coalesce(p_q, '')), '');
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  q := replace(replace(ltrim(q, '@'), '%', ''), '_', '\_');
  return coalesce((select jsonb_agg(x order by (x->>'joined') desc) from (
    select jsonb_build_object('id', u.id, 'name', pr.name, 'username', pr.username, 'photo', pr.photo, 'email', u.email,
      'joined', u.created_at, 'seen', u.last_sign_in_at,
      'tropas', (select count(*) from public.tropa_members m where m.user_id = u.id),
      'friends', (select count(*) from public.friendships f where f.status = 'accepted' and (f.a = u.id or f.b = u.id)),
      'owns', (select count(*) from public.place_claims c where c.user_id = u.id and c.status = 'approved'),
      'reported', (select count(*) from public.user_reports r where r.reported = u.id and not coalesce(r.handled, false)),
      'admin', exists (select 1 from public.admins a where a.user_id = u.id)) x
    from auth.users u left join public.profiles pr on pr.id = u.id
    where q is null or pr.name ilike '%' || q || '%' or pr.username ilike '%' || q || '%' or u.email ilike '%' || q || '%'
    order by u.created_at desc limit 50) s), '[]');
end $$;

-- Reports about people and about Pasabits
create or replace function public.people_reports_admin()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  return jsonb_build_object(
    'users', coalesce((select jsonb_agg(jsonb_build_object('id', r.id, 'reason', r.reason, 'note', r.note, 'at', r.created_at, 'handled', coalesce(r.handled, false),
        'who', r.reported, 'who_name', a.name, 'who_user', a.username, 'by', r.reporter, 'by_name', b.name, 'by_user', b.username,
        'msg', coalesce((select d.body from public.dm_messages d where d.id = r.message_id), (select t.body from public.tropa_messages t where t.id = r.message_id)))
        order by coalesce(r.handled, false), r.created_at desc)
      from public.user_reports r left join public.profiles a on a.id = r.reported left join public.profiles b on b.id = r.reporter), '[]'),
    'pasabits', coalesce((select jsonb_agg(jsonb_build_object('id', r.id, 'reason', r.reason, 'note', r.note, 'at', r.created_at, 'handled', coalesce(r.handled, false),
        'ps', r.pasabit_id, 'title', p.title, 'place', p.place, 'starts', p.starts_at, 'cancelled', p.cancelled_at is not null,
        'host', p.host, 'host_name', h.name, 'host_user', h.username, 'by', r.reporter, 'by_name', b.name, 'by_user', b.username)
        order by coalesce(r.handled, false), r.created_at desc)
      from public.pasabit_reports r join public.pasabits p on p.id = r.pasabit_id left join public.profiles h on h.id = p.host left join public.profiles b on b.id = r.reporter), '[]'));
end $$;

create or replace function public.report_handle(p_kind text, p_id bigint, p_handled boolean)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  if p_kind = 'user' then update public.user_reports set handled = p_handled where id = p_id;
  elsif p_kind = 'pasabit' then update public.pasabit_reports set handled = p_handled where id = p_id;
  else raise exception 'kind'; end if;
  if not found then raise exception 'not found'; end if;
end $$;

-- Cancel (or bring back) a Pasabit someone reported
create or replace function public.pasabit_admin_cancel(p_id uuid, p_cancel boolean)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  update public.pasabits set cancelled_at = case when p_cancel then now() else null end where id = p_id;
  if not found then raise exception 'not found'; end if;
end $$;

revoke all on function public.admin_overview(), public.owners_admin(), public.owner_remove(bigint), public.owner_restore(bigint), public.people_admin(text),
  public.people_reports_admin(), public.report_handle(text, bigint, boolean), public.pasabit_admin_cancel(uuid, boolean) from public, anon, authenticated;
grant execute on function public.admin_overview(), public.owners_admin(), public.owner_remove(bigint), public.owner_restore(bigint), public.people_admin(text),
  public.people_reports_admin(), public.report_handle(text, bigint, boolean), public.pasabit_admin_cancel(uuid, boolean) to authenticated;
notify pgrst, 'reload schema';
