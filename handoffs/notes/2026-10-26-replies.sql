-- Replies: a message can point to the one it answers (tropa, 1-on-1 and Pasabit chats). No foreign key on purpose:
-- if the original is deleted, the quote says "Message removed".
alter table public.tropa_messages add column if not exists reply_to bigint;
alter table public.dm_messages add column if not exists reply_to bigint;
alter table public.pasabit_messages add column if not exists reply_to bigint;

-- the short quote shown on top of a reply (only called from inside the chat functions, which check membership)
create or replace function public.tropa_rq(p bigint) returns jsonb language sql stable set search_path = '' as $$
  select case when p is null then null else coalesce((select jsonb_build_object('id', q.id, 'member', q.member_id, 'kind', q.kind, 'body', left(q.body, 140), 'name', coalesce(qm.nick, qm.name))
    from public.tropa_messages q left join public.tropa_members qm on qm.id = q.member_id where q.id = p), jsonb_build_object('id', p, 'gone', true)) end $$;
create or replace function public.dm_rq(p bigint) returns jsonb language sql stable set search_path = '' as $$
  select case when p is null then null else coalesce((select jsonb_build_object('id', q.id, 'member', q.sender, 'kind', 'msg', 'body', left(q.body, 140), 'name', pr.name)
    from public.dm_messages q left join public.profiles pr on pr.id = q.sender where q.id = p), jsonb_build_object('id', p, 'gone', true)) end $$;
create or replace function public.ps_rq(p bigint) returns jsonb language sql stable set search_path = '' as $$
  select case when p is null then null else coalesce((select jsonb_build_object('id', q.id, 'member', q.sender, 'kind', q.kind, 'body', left(q.body, 140), 'name', pr.name)
    from public.pasabit_messages q left join public.profiles pr on pr.id = q.sender where q.id = p), jsonb_build_object('id', p, 'gone', true)) end $$;
revoke all on function public.tropa_rq(bigint), public.dm_rq(bigint), public.ps_rq(bigint) from public, anon, authenticated;

do $mig$
declare r record; def text; s record;
begin
  -- the three send functions take an optional p_reply (old calls without it keep working)
  for s in select * from (values
    ('tropa_msg_send', 'public.tropa_msg_send(text, text, text, text)', 'p_body text)', 'anon, authenticated'),
    ('dm_send', 'public.dm_send(uuid, text)', 'p_body text)', 'authenticated'),
    ('ps_send', 'public.ps_send(uuid, text)', 'p_body text)', 'authenticated')
  ) as v(fn, sig, old, roles)
  loop
    select pg_get_functiondef(p.oid) into def from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = s.fn;
    if position(s.old || E'\n RETURNS' in def) = 0 then raise exception 'signature not found in %', s.fn; end if;
    def := replace(def, s.old || E'\n RETURNS', 'p_body text, p_reply bigint DEFAULT NULL::bigint)' || E'\n RETURNS');
    for r in select * from (values
      (1, 'tropa_msg_send', $o$insert into public.tropa_messages (tropa_id, member_id, kind, body) values (t.id, me, p_kind, b) returning * into r;$o$,
          $n$insert into public.tropa_messages (tropa_id, member_id, kind, body, reply_to) values (t.id, me, p_kind, b, (select q.id from public.tropa_messages q where q.id = p_reply and q.tropa_id = t.id)) returning * into r;$n$),
      (2, 'tropa_msg_send', $o$'emoji', m.emoji, 'hue', m.hue);$o$, $n$'emoji', m.emoji, 'hue', m.hue, 'reply', r.reply_to, 'rq', public.tropa_rq(r.reply_to));$n$),
      (3, 'dm_send', $o$insert into public.dm_messages (dm_id, sender, body) values (p_dm, me, b) returning * into r;$o$,
          $n$insert into public.dm_messages (dm_id, sender, body, reply_to) values (p_dm, me, b, (select q.id from public.dm_messages q where q.id = p_reply and q.dm_id = p_dm)) returning * into r;$n$),
      (4, 'dm_send', $o$'name', (select name from public.profiles where id = me));$o$, $n$'name', (select name from public.profiles where id = me), 'reply', r.reply_to, 'rq', public.dm_rq(r.reply_to));$n$),
      (5, 'ps_send', $o$insert into public.pasabit_messages (pasabit_id, sender, body) values (p_id, me, b) returning * into r;$o$,
          $n$insert into public.pasabit_messages (pasabit_id, sender, body, reply_to) values (p_id, me, b, (select q.id from public.pasabit_messages q where q.id = p_reply and q.pasabit_id = p_id)) returning * into r;$n$),
      (6, 'ps_send', $o$'name', (select name from public.profiles where id = me));$o$, $n$'name', (select name from public.profiles where id = me), 'reply', r.reply_to, 'rq', public.ps_rq(r.reply_to));$n$)
    ) as v(n, fn, old, new) where v.fn = s.fn order by n
    loop
      if position(r.old in def) = 0 then raise exception 'text not found in % (step %)', r.fn, r.n; end if;
      def := replace(def, r.old, r.new);
    end loop;
    execute 'drop function ' || s.sig;
    execute def;
    execute 'revoke all on function public.' || s.fn || '(' || case when s.fn = 'tropa_msg_send' then 'text, text, text, text' else 'uuid, text' end || ', bigint) from public, anon, authenticated';
    execute 'grant execute on function public.' || s.fn || '(' || case when s.fn = 'tropa_msg_send' then 'text, text, text, text' else 'uuid, text' end || ', bigint) to ' || s.roles;
  end loop;

  -- the chat loaders send the reply id and its quote with every message
  for r in select * from (values
    (7, 'tropa_chat', $o$'emoji', tm.emoji, 'hue', tm.hue) order by g.id)$o$, $n$'emoji', tm.emoji, 'hue', tm.hue, 'reply', g.reply_to, 'rq', public.tropa_rq(g.reply_to)) order by g.id)$n$),
    (8, 'dm_chat', $o$'at', g.created_at, 'name', p.name) order by g.id)$o$, $n$'at', g.created_at, 'name', p.name, 'reply', g.reply_to, 'rq', public.dm_rq(g.reply_to)) order by g.id)$n$),
    (9, 'ps_chat', $o$'at', g.created_at, 'name', pr.name) order by g.id)$o$, $n$'at', g.created_at, 'name', pr.name, 'reply', g.reply_to, 'rq', public.ps_rq(g.reply_to)) order by g.id)$n$)
  ) as v(n, fn, old, new) order by n
  loop
    select pg_get_functiondef(p.oid) into def from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = r.fn;
    if position(r.old in def) = 0 then raise exception 'text not found in % (step %)', r.fn, r.n; end if;
    execute replace(def, r.old, r.new);
  end loop;
end $mig$;
