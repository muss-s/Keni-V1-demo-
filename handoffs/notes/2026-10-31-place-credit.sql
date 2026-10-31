-- Place credit: opt-in "Show my name on places I add" (2026-10-31)
alter table public.profile_extras add column if not exists show_on_places boolean not null default false;

-- name + id of whoever first pinned a place, only if they opted in (else null)
create or replace function public.place_credit(p_place text) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('id', pr.id, 'name', coalesce(nullif(pr.name, ''), 'Someone'))
  from public.places pl
  join public.profile_extras e on e.user_id = pl.added_by and e.show_on_places
  join public.profiles pr on pr.id = pl.added_by
  where pl.id = p_place and pl.status = 'approved' and pl.visibility = 'public' and not pl.hidden
    and auth.uid() is not null
    and not exists (select 1 from public.blocks b where b.blocker = pl.added_by and b.blocked = auth.uid())
$$;

create or replace function public.place_credit_set(p_on boolean) returns void
language sql security definer set search_path = '' as $$
  insert into public.profile_extras (user_id, show_on_places) values (auth.uid(), coalesce(p_on, false))
  on conflict (user_id) do update set show_on_places = excluded.show_on_places
  where auth.uid() is not null
$$;

-- your own data: setting + approved places you added
create or replace function public.profile_mine() returns jsonb
language sql stable security definer set search_path = '' as $$
  select coalesce((select jsonb_build_object('fave', e.fave, 'about', e.about, 'saved', to_jsonb(e.saved), 'been', to_jsonb(e.been), 'privacy', e.privacy,
      'credit', e.show_on_places)
    from public.profile_extras e where e.user_id = auth.uid()), '{}'::jsonb)
    || jsonb_build_object('added', coalesce((select jsonb_agg(jsonb_build_object('id', p.id, 'name', p.name) order by p.created_at desc)
      from public.places p where p.added_by = auth.uid() and p.status = 'approved' and p.visibility = 'public' and not p.hidden), '[]'::jsonb)) $$;

-- profile_page: add 'credit_on' and 'added' (list only if it's you or they opted in)
do $$
declare d text; n text;
begin
  select pg_get_functiondef('public.profile_page(uuid)'::regprocedure) into d;
  n := replace(d, '''pasabits_up'', coalesce(', '''credit_on'', coalesce(e.show_on_places, false),
    ''added'', case when mine or coalesce(e.show_on_places, false) then (select coalesce(jsonb_agg(jsonb_build_object(''id'', p.id, ''name'', p.name) order by p.created_at desc), ''[]''::jsonb)
      from public.places p where p.added_by = p_user and p.status = ''approved'' and p.visibility = ''public'' and not p.hidden) end,
    ''pasabits_up'', coalesce(');
  if n = d then raise exception 'anchor not found'; end if;
  execute n;
end $$;

revoke all on function public.place_credit(text), public.place_credit_set(boolean) from public, anon;
grant execute on function public.place_credit(text), public.place_credit_set(boolean) to authenticated;
revoke all on function public.profile_mine(), public.profile_page(uuid) from public, anon;
grant execute on function public.profile_mine(), public.profile_page(uuid) to authenticated;
notify pgrst, 'reload schema';
