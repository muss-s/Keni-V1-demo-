-- Tropa photo: a small square JPEG (data URL) any member can set. Shows on chats, invites and the tropa list.
alter table public.tropas add column if not exists photo text
  check (photo is null or (photo like 'data:image/%' and char_length(photo) <= 120000));
-- a "Ganda changed the tropa photo" line in the chat
alter table public.tropa_messages drop constraint if exists tropa_messages_kind_check;
alter table public.tropa_messages add constraint tropa_messages_kind_check check (kind = any (array['msg', 'poke', 'sys']));

create or replace function public.tropa_set_photo(p_code text, p_secret text, p_photo text)
returns text language plpgsql security definer set search_path = '' as $$
declare t public.tropas; me uuid; who text;
begin
  select * into t from public.tropas where code = upper(p_code);
  if not found then raise exception 'no such tropa'; end if;
  me := public.tropa_me(t.id, p_secret); if me is null then raise exception 'not a member'; end if;
  if p_photo is not null and (p_photo not like 'data:image/%' or char_length(p_photo) > 120000) then raise exception 'photo too big'; end if;
  if (select count(*) from public.tropa_messages where tropa_id = t.id and member_id = me and kind = 'sys' and created_at > now() - interval '1 minute') >= 3 then
    raise exception 'slow down';
  end if;
  update public.tropas set photo = p_photo, updated_at = now() where id = t.id;
  select split_part(trim(coalesce(name, 'Someone')), ' ', 1) into who from public.tropa_members where id = me;
  insert into public.tropa_messages (tropa_id, member_id, kind, body)
    values (t.id, me, 'sys', coalesce(who, 'Someone') || case when p_photo is null then ' removed the tropa photo' else ' changed the tropa photo' end);
  return 'ok';
end $$;
revoke all on function public.tropa_set_photo(text, text, text) from public;
grant execute on function public.tropa_set_photo(text, text, text) to anon, authenticated;

-- the photo comes back with the tropa, the chat inbox, your tropas, and tropa invites
do $mig$
declare r record; def text;
begin
  for r in select * from (values
    (1, 'tropa_get', $o$'emoji', t.emoji, 'state'$o$, $n$'emoji', t.emoji, 'photo', t.photo, 'state'$n$),
    (2, 'chat_inbox', $o$'emoji', t.emoji, 'me', me$o$, $n$'emoji', t.emoji, 'photo', t.photo, 'me', me$n$),
    (3, 'tropa_mine', $o$'emoji', t.emoji, 'me', m.id$o$, $n$'emoji', t.emoji, 'photo', t.photo, 'me', m.id$n$),
    (4, 'tropa_invite', $o$jsonb_build_object('code', t.code, 'name', t.name, 'emoji', t.emoji)$o$, $n$jsonb_build_object('code', t.code, 'name', t.name, 'emoji', t.emoji, 'photo', t.photo)$n$)
  ) as v(n, fn, old, new) order by n
  loop
    select pg_get_functiondef(p.oid) into def from pg_proc p join pg_namespace s on s.oid = p.pronamespace where s.nspname = 'public' and p.proname = r.fn;
    if def is null then raise exception 'missing function %', r.fn; end if;
    if position(r.old in def) = 0 then raise exception 'text not found in % (step %)', r.fn, r.n; end if;
    execute replace(def, r.old, r.new);
  end loop;
end $mig$;
