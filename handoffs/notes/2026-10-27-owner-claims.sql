-- Owner side, steps 1 + 2 (2026-10-27): real place claims checked by the Keni team, then owner tools.
-- A claim is a row in place_claims. status approved = that person manages the place (several people can manage one place).
-- Everything goes through security definer RPCs; the table has no policies, so nobody reads it directly.

create table public.place_claims (
  id bigint generated always as identity primary key,
  place_id text not null references public.places(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'manager', 'staff')),
  contact text not null check (length(contact) between 3 and 80),
  note text check (note is null or length(note) <= 300),
  proof_path text check (proof_path is null or proof_path ~ '^[0-9a-f-]{36}/[0-9a-f]{24}\.jpg$'),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  reason text check (reason is null or length(reason) <= 200),
  prev_level text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid
);
comment on table public.place_claims is 'People asking to manage a place on Keni. status approved = they manage it (Studio). Read and changed only through the claim_* and owner_* functions.';
create unique index place_claims_live on public.place_claims (place_id, user_id) where status in ('pending', 'approved');
create index place_claims_user on public.place_claims (user_id);
alter table public.place_claims enable row level security;
revoke all on public.place_claims from anon, authenticated;

-- every owner edit is kept, so a bad edit can be undone
create table public.place_edits (
  id bigint generated always as identity primary key,
  place_id text not null references public.places(id) on delete cascade,
  user_id uuid not null,
  before jsonb not null,
  after jsonb not null,
  created_at timestamptz not null default now()
);
comment on table public.place_edits is 'Each listing edit an owner made in Studio: the fields before and after. For undoing bad edits.';
create index place_edits_place on public.place_edits (place_id, created_at desc);
alter table public.place_edits enable row level security;
revoke all on public.place_edits from anon, authenticated;
create policy "admins can see owner edits" on public.place_edits for select to authenticated using (public.is_admin());
grant select on public.place_edits to authenticated;

-- proof photos (a business permit, a sign...): private, only the sender and admins can see them
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('claim-proofs', 'claim-proofs', false, 3145728, array['image/jpeg']) on conflict (id) do nothing;
create policy "claim proofs: upload to own folder" on storage.objects for insert to authenticated
  with check (bucket_id = 'claim-proofs' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "claim proofs: see own or admin" on storage.objects for select to authenticated
  using (bucket_id = 'claim-proofs' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));
create policy "claim proofs: delete own or admin" on storage.objects for delete to authenticated
  using (bucket_id = 'claim-proofs' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

-- owners' cover photos go in the (public) place-photos bucket, in their own folder
create policy "place photos: upload to own folder" on storage.objects for insert to authenticated
  with check (bucket_id = 'place-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "place photos: see own or admin" on storage.objects for select to authenticated
  using (bucket_id = 'place-photos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));
create policy "place photos: delete own or admin" on storage.objects for delete to authenticated
  using (bucket_id = 'place-photos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

create or replace function public.is_place_owner(p_place text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.place_claims where place_id = p_place and user_id = auth.uid() and status = 'approved') $$;

-- send a claim
create or replace function public.claim_send(p_place text, p_role text, p_contact text, p_note text default null, p_proof text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); pl public.places; c public.place_claims; a record;
begin
  if me is null then raise exception 'signin'; end if;
  select * into pl from public.places where id = p_place;
  if not found or coalesce(pl.hidden, false) or not ((pl.visibility is null or pl.visibility = 'public') and coalesce(pl.status, 'approved') = 'approved' or pl.added_by = me) then raise exception 'no such place'; end if;
  if exists (select 1 from public.place_claims where place_id = p_place and user_id = me and status = 'approved') then raise exception 'already yours'; end if;
  if exists (select 1 from public.place_claims where place_id = p_place and user_id = me and status = 'pending') then raise exception 'already waiting'; end if;
  if (select count(*) from public.place_claims where user_id = me and status = 'pending') >= 3 then raise exception 'too many waiting'; end if;
  if p_proof is not null and split_part(p_proof, '/', 1) <> me::text then raise exception 'bad proof'; end if;
  insert into public.place_claims (place_id, user_id, role, contact, note, proof_path)
  values (p_place, me, p_role, btrim(left(p_contact, 80)), nullif(btrim(left(coalesce(p_note, ''), 300)), ''), p_proof) returning * into c;
  for a in select user_id from public.admins loop
    perform public.push_enqueue_user(a.user_id, 'New place claim', coalesce(pl.name, 'A place') || ' is waiting for a check.', 'claim-' || c.id, '/admin');
  end loop;
  return jsonb_build_object('id', c.id, 'status', c.status, 'at', c.created_at);
end $$;

-- cancel a claim that is waiting, or stop managing a place. Returns the proof path so the app can delete the file.
create or replace function public.claim_cancel(p_id bigint)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare c public.place_claims;
begin
  if auth.uid() is null then raise exception 'signin'; end if;
  delete from public.place_claims where id = p_id and user_id = auth.uid() returning * into c;
  if not found then raise exception 'not found'; end if;
  return jsonb_build_object('id', c.id, 'proof', c.proof_path);
end $$;

-- my claims and the places I manage
create or replace function public.claims_mine()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then return '[]'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', c.id, 'place', c.place_id, 'name', p.name, 'photo', p.photo, 'area', p.area, 'role', c.role,
      'status', c.status, 'reason', c.reason, 'at', c.created_at, 'reviewed_at', c.reviewed_at,
      'reports', case when c.status = 'approved' then (select count(*) from public.reports r where r.place_id = c.place_id and r.status = 'new') end)
    order by (c.status = 'approved') desc, c.created_at desc)
    from public.place_claims c join public.places p on p.id = c.place_id where c.user_id = me), '[]');
end $$;

-- admin: claims waiting for a check
create or replace function public.claims_pending()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', c.id, 'place_id', c.place_id, 'place', p.name, 'addr', p.addr, 'area', p.area, 'level', p.level,
      'place_contacts', p.contacts, 'photo', p.photo, 'role', c.role, 'contact', c.contact, 'note', c.note, 'proof', c.proof_path, 'at', c.created_at,
      'user', c.user_id, 'by', coalesce(pr.name, 'Someone'), 'username', pr.username, 'email', u.email,
      'managers', (select count(*) from public.place_claims x where x.place_id = c.place_id and x.status = 'approved'),
      'added_it', p.added_by = c.user_id)
    order by c.created_at)
    from public.place_claims c join public.places p on p.id = c.place_id left join public.profiles pr on pr.id = c.user_id left join auth.users u on u.id = c.user_id
    where c.status = 'pending'), '[]');
end $$;

-- admin: approve or reject a claim. Approving a small pin makes it a full listing, so the owner can fill it in.
create or replace function public.claim_review(p_id bigint, p_ok boolean, p_reason text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare c public.place_claims; pname text; lvl text;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  select level, name into lvl, pname from public.places where id = (select place_id from public.place_claims where id = p_id);
  update public.place_claims set status = case when p_ok then 'approved' else 'rejected' end, reviewed_at = now(), reviewed_by = auth.uid(),
    reason = case when p_ok then null else nullif(btrim(left(coalesce(p_reason, ''), 200)), '') end, prev_level = lvl
    where id = p_id and status = 'pending' returning * into c;
  if not found then raise exception 'not waiting'; end if;
  if p_ok and lvl = 'basic' then update public.places set level = 'full' where id = c.place_id; end if;
  perform public.notify(c.user_id, case when p_ok then 'claim_ok' else 'claim_no' end, null, jsonb_build_object('place', c.place_id, 'name', pname, 'reason', c.reason));
  perform public.push_enqueue_user(c.user_id, coalesce(pname, 'Keni'),
    case when p_ok then 'You can now manage ' || coalesce(pname, 'your place') || ' on Keni. Open your Studio to update it.'
      else 'Your claim for ' || coalesce(pname, 'this place') || ' wasn’t approved' || coalesce(': ' || c.reason, '') || '.' end, 'claim-' || c.id, '/#studio');
  return jsonb_build_object('id', c.id, 'status', c.status);
end $$;

create or replace function public.claim_unreview(p_id bigint)
returns text language plpgsql security definer set search_path = '' as $$
declare c public.place_claims;
begin
  if not public.is_admin() then raise exception 'admins only'; end if;
  select * into c from public.place_claims where id = p_id;
  if not found then raise exception 'not found'; end if;
  if c.status = 'approved' and c.prev_level = 'basic' then update public.places set level = 'basic' where id = c.place_id; end if;
  update public.place_claims set status = 'pending', reviewed_at = null, reviewed_by = null, reason = null, prev_level = null where id = p_id;
  delete from public.notifications where kind in ('claim_ok', 'claim_no') and created_at > now() - interval '10 minutes'
    and user_id = c.user_id and data ->> 'place' = c.place_id;
  return 'ok';
end $$;

-- owner: edit the listing. Only the keys sent are changed. Name and pin stay with the Keni team (a report asks for those).
create or replace function public.owner_update(p_place text, p jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.places; b jsonb; a jsonb; x jsonb; k text; n numeric; m numeric;
  pfx text := 'https://wlxkdivnktxdbwbertjw.supabase.co/storage/v1/object/public/place-photos/';
begin
  if me is null then raise exception 'signin'; end if;
  if not public.is_place_owner(p_place) then raise exception 'not yours'; end if;
  if jsonb_typeof(p) <> 'object' then raise exception 'bad input'; end if;
  select * into r from public.places where id = p_place for update;
  b := jsonb_build_object('blurb', r.blurb, 'hours', r.hours, 'days', r.days, 'off_days', to_jsonb(r.off_days), 'hours_note', r.hours_note,
    'price', r.price, 'contacts', r.contacts, 'perks', to_jsonb(r.perks), 'photo', r.photo);

  if p ? 'blurb' then r.blurb := left(btrim(coalesce(p->>'blurb', '')), 300); end if;
  if p ? 'hours_note' then r.hours_note := nullif(left(btrim(coalesce(p->>'hours_note', '')), 120), ''); end if;
  if p ? 'price' then
    if jsonb_typeof(p->'price') = 'null' then r.price := null;
    elsif (p->>'price')::int between 0 and 4 then r.price := (p->>'price')::smallint; else raise exception 'price'; end if;
  end if;
  -- hours: [open, close] in hours (0.5 steps); close can go past 24 (after midnight). days: {"0".."6": [open, close]}. off_days: weekdays closed (0 = Sunday)
  if p ? 'hours' then
    x := p->'hours';
    if jsonb_typeof(x) = 'null' then r.hours := null;
    else
      if jsonb_typeof(x) <> 'array' or jsonb_array_length(x) <> 2 then raise exception 'hours'; end if;
      n := (x->>0)::numeric; m := (x->>1)::numeric;
      if n < 0 or n > 23.5 or m <= n or m > 30 or m - n > 24 then raise exception 'hours'; end if;
      r.hours := x;
    end if;
  end if;
  if p ? 'days' then
    x := p->'days';
    if jsonb_typeof(x) = 'null' or x = '{}'::jsonb then r.days := null;
    else
      if jsonb_typeof(x) <> 'object' then raise exception 'days'; end if;
      for k in select jsonb_object_keys(x) loop
        if k !~ '^[0-6]$' or jsonb_typeof(x->k) <> 'array' or jsonb_array_length(x->k) <> 2 then raise exception 'days'; end if;
        n := (x->k->>0)::numeric; m := (x->k->>1)::numeric;
        if n < 0 or n > 23.5 or m <= n or m > 30 or m - n > 24 then raise exception 'days'; end if;
      end loop;
      r.days := x;
    end if;
  end if;
  if p ? 'off_days' then
    if jsonb_typeof(p->'off_days') <> 'array' then raise exception 'off_days'; end if;
    r.off_days := array(select distinct v::int from jsonb_array_elements_text(p->'off_days') v where v ~ '^[0-6]$' order by 1);
  end if;
  if p ? 'contacts' then
    x := p->'contacts';
    if jsonb_typeof(x) <> 'object' then raise exception 'contacts'; end if;
    r.contacts := (select coalesce(jsonb_object_agg(e.key, left(btrim(e.value), 80)), '{}'::jsonb)
      from jsonb_each_text(x) e where e.key in ('phone', 'fb', 'ig', 'web', 'tiktok') and btrim(coalesce(e.value, '')) <> '' and e.value !~ '[<>"]');
  end if;
  if p ? 'perks' then
    if jsonb_typeof(p->'perks') <> 'array' then raise exception 'perks'; end if;
    r.perks := array(select distinct left(v, 12) from jsonb_array_elements_text(p->'perks') v where v ~ '^[a-z]{2,12}$' limit 15);
  end if;
  if p ? 'photo' then
    if jsonb_typeof(p->'photo') = 'null' then r.photo := null;
    elsif (p->>'photo') = coalesce(r.photo, '') then null;
    elsif (p->>'photo') ~ ('^' || replace(pfx, '.', '\.') || me::text || '/[0-9a-f]{24}\.jpg$') then r.photo := p->>'photo';
    else raise exception 'photo'; end if;
  end if;

  update public.places set blurb = r.blurb, hours = r.hours, days = r.days, off_days = r.off_days, hours_note = r.hours_note, price = r.price,
    contacts = r.contacts, perks = r.perks, photo = r.photo, updated_at = now()
  where id = p_place;
  a := jsonb_build_object('blurb', r.blurb, 'hours', r.hours, 'days', r.days, 'off_days', to_jsonb(r.off_days), 'hours_note', r.hours_note,
    'price', r.price, 'contacts', r.contacts, 'perks', to_jsonb(r.perks), 'photo', r.photo);
  if a is distinct from b then insert into public.place_edits (place_id, user_id, before, after) values (p_place, me, b, a); end if;
  return a;
end $$;

-- owner: problems people reported about the place (who reported stays private)
create or replace function public.owner_reports(p_place text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_place_owner(p_place) then raise exception 'not yours'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', r.id, 'reason', r.reason, 'kind', r.kind, 'note', r.note, 'status', r.status, 'at', r.created_at) order by r.created_at desc)
    from (select * from public.reports where place_id = p_place order by created_at desc limit 50) r), '[]');
end $$;

revoke all on function public.is_place_owner(text), public.claim_send(text, text, text, text, text), public.claim_cancel(bigint), public.claims_mine(),
  public.claims_pending(), public.claim_review(bigint, boolean, text), public.claim_unreview(bigint), public.owner_update(text, jsonb), public.owner_reports(text)
  from public, anon, authenticated;
grant execute on function public.is_place_owner(text), public.claim_send(text, text, text, text, text), public.claim_cancel(bigint), public.claims_mine(),
  public.claims_pending(), public.claim_review(bigint, boolean, text), public.claim_unreview(bigint), public.owner_update(text, jsonb), public.owner_reports(text)
  to authenticated;
notify pgrst, 'reload schema';
