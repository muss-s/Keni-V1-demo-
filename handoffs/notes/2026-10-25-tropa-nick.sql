-- Tropa nicknames: anyone in a tropa can give anyone in it a nickname (only inside that tropa). Chats, the inbox and pushes show it.
alter table public.tropa_members add column if not exists nick text check (nick is null or char_length(nick) between 1 and 20);

create or replace function public.tropa_set_nick(p_code text, p_secret text, p_member uuid, p_nick text)
returns text language plpgsql security definer set search_path = '' as $$
declare t public.tropas; me uuid; tg public.tropa_members; who text; n text := nullif(trim(regexp_replace(coalesce(p_nick, ''), '\s+', ' ', 'g')), '');
begin
  select * into t from public.tropas where code = upper(p_code);
  if not found then raise exception 'no such tropa'; end if;
  me := public.tropa_me(t.id, p_secret); if me is null then raise exception 'not a member'; end if;
  select * into tg from public.tropa_members where id = p_member and tropa_id = t.id;
  if not found then raise exception 'not in this tropa'; end if;
  if n is not null and char_length(n) > 20 then raise exception 'too long'; end if;
  if n is not distinct from tg.nick then return 'ok'; end if;
  if (select count(*) from public.tropa_messages where tropa_id = t.id and member_id = me and kind = 'sys' and created_at > now() - interval '1 minute') >= 5 then
    raise exception 'slow down';
  end if;
  update public.tropa_members set nick = n where id = tg.id;
  select coalesce(nullif(split_part(trim(name), ' ', 1), ''), 'Someone') into who from public.tropa_members where id = me;
  insert into public.tropa_messages (tropa_id, member_id, kind, body) values (t.id, me, 'sys',
    who || case
      when n is null and tg.id = me then ' cleared their nickname'
      when n is null then ' cleared ' || coalesce(nullif(split_part(trim(tg.name), ' ', 1), ''), 'someone') || '’s nickname'
      when tg.id = me then ' set their nickname to ' || n
      else ' set ' || coalesce(nullif(split_part(trim(tg.name), ' ', 1), ''), 'someone') || '’s nickname to ' || n end);
  return 'ok';
end $$;
revoke all on function public.tropa_set_nick(text, text, uuid, text) from public;
grant execute on function public.tropa_set_nick(text, text, uuid, text) to anon, authenticated;

-- the nickname wherever a tropa member's name is shown
do $mig$
declare r record; def text;
begin
  for r in select * from (values
    (1, 'tropa_member_json', $o$'name', m.name, 'emoji'$o$, $n$'name', m.name, 'nick', m.nick, 'emoji'$n$),
    (2, 'tropa_chat', $o$'name', tm.name, 'emoji', tm.emoji$o$, $n$'name', coalesce(tm.nick, tm.name), 'emoji', tm.emoji$n$),
    (3, 'tropa_chat', $o$'name', m.name, 'emoji', m.emoji, 'hue', m.hue, 'photo', m.photo)$o$, $n$'name', coalesce(m.nick, m.name), 'nick', m.nick, 'real', m.name, 'emoji', m.emoji, 'hue', m.hue, 'photo', m.photo)$n$),
    (4, 'tropa_msgs', $o$g.created_at as at, tm.name,$o$, $n$g.created_at as at, coalesce(tm.nick, tm.name) as name,$n$),
    (5, 'tropa_msgs2', $o$g.created_at as at, tm.name,$o$, $n$g.created_at as at, coalesce(tm.nick, tm.name) as name,$n$),
    (6, 'tropa_msg_send', $o$who := coalesce(nullif(split_part(m.name, ' ', 1), ''), 'Someone');$o$, $n$who := coalesce(m.nick, nullif(split_part(m.name, ' ', 1), ''), 'Someone');$n$),
    (7, 'tropa_msg_send', $o$'name', m.name, 'emoji', m.emoji$o$, $n$'name', coalesce(m.nick, m.name), 'emoji', m.emoji$n$),
    (8, 'chat_inbox', $o$'at', g.created_at, 'name', tm.name)$o$, $n$'at', g.created_at, 'name', coalesce(tm.nick, tm.name))$n$),
    (9, 'chat_inbox', $o$'name', m.name, 'emoji', m.emoji, 'hue', m.hue, 'photo', m.photo)$o$, $n$'name', coalesce(m.nick, m.name), 'emoji', m.emoji, 'hue', m.hue, 'photo', m.photo)$n$)
  ) as v(n, fn, old, new) order by n
  loop
    select pg_get_functiondef(p.oid) into def from pg_proc p join pg_namespace s on s.oid = p.pronamespace where s.nspname = 'public' and p.proname = r.fn;
    if def is null then raise exception 'missing function %', r.fn; end if;
    if position(r.old in def) = 0 then raise exception 'text not found in % (step %)', r.fn, r.n; end if;
    execute replace(def, r.old, r.new);
  end loop;
end $mig$;
