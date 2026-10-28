-- Keni · owner numbers (2026-10-28). Counts how many phones opened or saved a place, once per phone per day.
-- place_hit is called by the app (anon ok). The place's own managers are not counted.
-- owner_stats gives a manager the last 14 days per day. Undo: drop the two functions and the table.

create table public.place_hits (
  place_id text not null references public.places(id) on delete cascade,
  day date not null default ((now() at time zone 'Asia/Manila')::date),
  device text not null check (device ~ '^[0-9a-f]{32}$'),
  kind text not null check (kind in ('view', 'save')),
  primary key (place_id, day, kind, device)
);
alter table public.place_hits enable row level security;
revoke all on public.place_hits from anon, authenticated;
comment on table public.place_hits is 'One row per phone per place per day per kind (view/save). Written by place_hit, read by owner_stats.';

create or replace function public.place_hit(p_place text, p_device text, p_kind text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if p_device is null or p_device !~ '^[0-9a-f]{32}$' or p_kind is null or p_kind not in ('view', 'save') then return; end if;
  if auth.uid() is not null and public.is_place_owner(p_place) then return; end if;
  if not exists (select 1 from public.places where id = p_place) then return; end if;
  insert into public.place_hits (place_id, device, kind) values (p_place, p_device, p_kind) on conflict do nothing;
end $$;

create or replace function public.owner_stats(p_place text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare today date := public.mnl_today();
begin
  if not public.is_place_owner(p_place) then raise exception 'not yours'; end if;
  return (select jsonb_agg(jsonb_build_object('day', d::date,
      'views', (select count(*) from public.place_hits h where h.place_id = p_place and h.day = d::date and h.kind = 'view'),
      'saves', (select count(*) from public.place_hits h where h.place_id = p_place and h.day = d::date and h.kind = 'save')) order by d)
    from generate_series(today - 13, today, interval '1 day') d);
end $$;

revoke all on function public.place_hit(text, text, text), public.owner_stats(text) from public, anon, authenticated;
grant execute on function public.place_hit(text, text, text) to anon, authenticated;
grant execute on function public.owner_stats(text) to authenticated;
notify pgrst, 'reload schema';
