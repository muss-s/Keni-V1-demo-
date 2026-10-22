-- Push notifications: name first, then the message. No emoji, no extra labels.
-- Direct chat: "Name" / message. Group chat: "Name · group" / message. Invites and requests: "Name" / what they did.
do $mig$
declare
  r record; def text;
begin
  for r in select * from (values
    (1, 'friend_respond', $o$'🤝 New friend', public.first_name(me) || ' accepted your friend request'$o$, $n$public.first_name(me), 'Accepted your friend request'$n$),
    (2, 'friend_request', $o$'🤝 New friend', public.first_name(me) || ' accepted your friend request'$o$, $n$public.first_name(me), 'Accepted your friend request'$n$),
    (3, 'friend_request', $o$'👋 Friend request', public.first_name(me) || ' wants to be friends on Keni'$o$, $n$public.first_name(me), 'Wants to be friends'$n$),
    (4, 'push_on_join', $o$'🎉 New in ' || t.name, coalesce(new.name, 'Someone') || ' joined the tropa'$o$, $n$coalesce(new.name, 'Someone') || ' · ' || t.name, 'Joined the tropa'$n$),
    (5, 'push_on_tropa', $o$'🗳️ Vote now!', lbl || ' is picking a place. Vote before time runs out.'$o$, $n$new.name, 'Picking a place. Vote before time runs out.'$n$),
    (6, 'push_on_tropa', $o$'🔒 Plan locked!', lbl || ': ' || coalesce(pname, 'your spot')$o$, $n$new.name, 'Plan locked: ' || coalesce(pname, 'your spot')$n$),
    (7, 'push_rate_reminders', $o$'😍 How was ' || coalesce(pname, 'your hangout') || '?', 'One tap to rate it. It keeps your tropa’s streak going 🔥'$o$, $n$'How was ' || coalesce(pname, 'your hangout') || '?', 'One tap to rate it. It keeps your tropa’s streak going'$n$),
    (8, 'tropa_msg_send', $o$trim(coalesce(t.emoji, '') || ' ' || t.name),
    who || ': ' || case when p_kind$o$, $n$who || ' · ' || t.name,
    case when p_kind$n$),
    (9, 'tropa_poke_answer', $o$trim(coalesce(t.emoji, '') || ' ' || t.name),
      who || ': ' || public.poke_answer_text$o$, $n$who || ' · ' || t.name,
      public.poke_answer_text$n$),
    (10, 'ps_send', $o$p.emoji || ' ' || p.title, who || ': ' || b, 'psc-'$o$, $n$who || ' · ' || p.title, b, 'psc-'$n$),
    (11, 'ps_join', $o$p.emoji || ' ' || p.title, who || ' is asking to tag along'$o$, $n$who || ' · ' || p.title, 'Asking to tag along'$n$),
    (12, 'ps_join', $o$p.emoji || ' ' || p.title, who || ' tagged along 🙋'$o$, $n$who || ' · ' || p.title, 'Tagged along'$n$),
    (13, 'ps_answer', $o$p.emoji || ' ' || p.title, 'You’re in! ' || public.first_name(me) || ' accepted you 🙌'$o$, $n$public.first_name(me) || ' · ' || p.title, 'Accepted you. You’re in!'$n$),
    (14, 'tropa_invite', $o$'🧲 Tropa invite', public.first_name(me) || ' invited you to ' || coalesce(t.emoji || ' ', '') || t.name$o$, $n$public.first_name(me), 'Invited you to ' || t.name$n$),
    (15, 'ps_cancel', $o$p.emoji || ' ' || p.title, 'Cancelled by ' || public.first_name(me)$o$, $n$public.first_name(me) || ' · ' || p.title, 'Cancelled the Pasabit'$n$),
    (16, 'ps_remind', $o$p.emoji || ' ' || p.title, 'Starts in 1 hour · ' || p.place$o$, $n$p.title, 'Starts in 1 hour · ' || p.place$n$)
  ) as v(n, fn, old, new) order by n
  loop
    select pg_get_functiondef(p.oid) into def from pg_proc p join pg_namespace s on s.oid = p.pronamespace where s.nspname = 'public' and p.proname = r.fn;
    if def is null then raise exception 'missing function %', r.fn; end if;
    if position(r.old in def) = 0 then raise exception 'text not found in % (step %)', r.fn, r.n; end if;
    execute replace(def, r.old, r.new);
  end loop;
end $mig$;
