# Keni: live state
Read this first. Background, rules and code anchors are in `../HANDOFF.md`.

## Now
- 2026-10-21 Claude: **PWA is LIVE** on keni-real.vercel.app. Manifest, sw.js, icons and headers are checked. It hasn't been installed on a real phone yet.
- 2026-10-22 Claude: GitHub is up to date: keni-real `4f26bf7`. Push with every deploy.

- 2026-10-21 Claude: **Push notifications are LIVE (backend and app).** No real phone has subscribed yet, so no real notification has been tested. The user declined a "send test" button.

- 2026-10-21 Claude: The user didn’t like the status-bar strip, so it’s removed (LIVE since 2026-10-22). The Tropa-page logo fix stays. Don't add a status-bar strip again: the user prefers content scrolling under the clock.

- 2026-10-22 Claude: Long press on the map no longer triggers iPhone text selection (the blue tint and handle): `user-select`/`touch-callout` set to none on `#mapview` and `.kring`. LIVE. Undo: `backups/real-index-before-holdselect.html`.

- 2026-10-22 Claude: Vote-card photos vanished after voting because the plan reconciler (`patchAttrs`) dropped the img's `ready` class. Now it keeps `ready` when the src is unchanged. LIVE. Undo: `backups/real-index-before-votephotos.html`.

- 2026-10-22 Claude: **Tropa chat and pokes are LIVE (DB and app).** DB migration `tropa_chat_and_pokes` adds `tropa_messages`, `tropa_msg_send` (members only; pokes 1 per 30s, messages 20/min; sends push to the others) and `tropa_msgs`. The app adds a 💬 chip in Tropa mode (unread badge) and 💬 Chat in My tropas, with a chat sheet that has a poke row (`K.tchat`, live channel `tchat-<code>`). Tested in the preview with faked server replies; DB has 0 messages. Undo: `backups/real-index-before-chat.html`.

- 2026-10-22 Claude: **Tropa mode update is LIVE** (deployed 2026-10-22, checked on the live site, not yet tried on real phones).
  - Tabs: 🗓️ Plan | 💬 Chat, with the chat as a full page. Unread badges show on the Chat tab and on the dock's Tropa button.
  - The steps are now 3: Tonight · Vote · Locked. "Who's going" only shows when the tropa changed.
  - The planner sets the time (chips or Other). The time shows on the locked card, in the share text and in the push.
  - Places closed at that time are left out of the vote.
  - Pokes are now polls: answer buttons, faces, and "Plan it →".
  - DB migration `poke_polls_and_plan_time` is applied (`tropa_msgs2`, `tropa_poke_answer`, `tropa_poke_answers`).
  - Tested in the preview with faked server calls.
  - Undo: `backups/real-index-before-tropa-update.html`.
  - Warning: the preview is signed in to the user's real tropa E44PARV, so stub `K.sb.rpc` before testing. A test lock once synced to it and was reverted right away; no push was sent.

- 2026-10-22 Claude: **Messenger-style Chats is LIVE.** It was deployed just before the user said "stop, build everything first before you deploy". From now on, build friends and Pasabit fully and deploy once at the end.
  - 💬 Chats is a dock button with an unread badge. It opens a full-screen inbox (every shared tropa), then the chat.
  - The chat has typing dots, "Seen" faces, long-press reactions (double-tap for ❤️), 👋 pokes in a tray, compact one-row poll chips, "Active now", older messages on scroll-up, Sending/Not-sent states and Back-button support.
  - The Plan/Chat tabs in Tropa mode are removed.
  - The dock fix: a rule I added had moved the Tropa circle; the dock is now resized to fit 4 buttons on a 360px phone.
  - DB migration `messenger_seen_reactions_inbox` adds `tropa_members.last_read`, `tropa_msg_reactions`, `tropa_chat`, `tropa_read`, `tropa_react` and `chat_inbox`, plus shorter poll labels. Tested with a rolled-back transaction.
  - The client module `Keni · Chats` is at the end of index.html.
  - Undo: `backups/real-index-before-messenger.html`.
- 2026-10-22 Claude: **Friends + 1-on-1 chats + 🔔 Activity are LIVE** (deployed 2026-10-22 with Pasabit; not yet tried on real phones).
  - DB: migrations `friends_dms_blocks_notifications` and `chat_links_and_member_accounts` (tested in a rolled-back transaction with fake accounts).
  - Inbox: a row of friends' faces; 🔔 Activity (friend requests, accepts); 👥 Friends (requests, friends, "From your tropas", sent, blocked, share link + QR); someone's card (#friend=<id>); ⋯ menu (Remove friend / Report / Block).
  - Pushes open the right place (sw.js `postMessage keniOpen`). `toast()` takes an optional button label.
  - Undo: `backups/real-index-before-friends.html`, `backups/real-sw-before-friends.js`.
- 2026-10-22 Claude: **Pasabit is back on the real backend and LIVE** (deployed 2026-10-22; not yet tried on real phones).
  - DB migration `pasabits`: tables `pasabits`, `pasabit_members`, `pasabit_messages`, `pasabit_reactions`, `pasabit_reports`; `ps_*` RPCs.
  - pg_cron `keni-pasabit-reminders` runs every 10 min and sends "starts in 1 hour".
  - Friends-only or open, with optional host approval. A group chat (kind "p") lives in Chats. Activity shows requests, joins, accepts and cancels. #ps=<id> links work.
  - Tested in a rolled-back transaction and in the preview with fake data. DB has 0 rows.
  - The map hook is now chained (it used to overwrite others).
  - Undo: `backups/real-index-before-pasabit.html`.
  - Not built: admin pages for user/Pasabit reports (rows go to `user_reports` / `pasabit_reports`), Studio owner events (`postOwner` is a stub).
- 2026-10-22 Claude: **Profiles + friends batch is LIVE** (deployed 2026-10-22, keni-real `730e174`; not yet tried on real phones). Everything below in this entry is live:
  - Your page opens from your dock photo. Anyone's page opens from their face (chats, Activity, Pasabit host and people, #friend= links). My code shows a QR.
  - Module `Keni · profile pages` is at the end of index.html. Chats now has `K.tchat.dm/more/card`.
  - DB migration `profile_pages` is applied (`profile_extras`, `profile_sync`, `profile_mine`, `profile_page`).
  - The Account list uses Keni line icons in glowing tiles (user said emoji looked generic).
  - Tropa invites from friends: the invite sheet shows friends' faces (tap = invite). They get a push + an Activity row with Join, which opens the usual join screen. DB migration `tropa_invite_friends` (`tropa_invite`, tested rolled back). Undo: `backups/real-index-before-tropa-invite.html`.
  - More ways to add friends: Friends search finds anyone by @username or name ("On Keni"), "People you may know" (friends of friends), and after "We went!" a sheet to add the people you went with. DB migration `friend_search_suggest` (`user_search`, `friend_suggest`, `friend_statuses`; tested rolled back). Undo: `backups/real-index-before-friend-search.html`.
  - Delete chats: swipe left in the inbox (asks first). It hides the chat for you only (S.chatClears + DB `chat_clears`); a new message brings it back. The host is asked after "We went!" whether to delete the Pasabit group chat for everyone (`ps_chat_delete`). DB migration `chat_delete`. Undo: `backups/real-index-before-chat-delete.html`.
  - An account is now required: "Skip for now" is gone, people who aren't signed in land on the welcome screen, and tropa links ask you to sign in first. Undo: `backups/real-index-before-account-required.html`.
  - Chats, Friends and profile pages use Keni line icons (`K.lic`) instead of emoji: header, search, buttons, empty states. Undo: `backups/real-index-before-icons.html`.
  - Dock: the left Tropa button is now Friends (opens the Friends screen; Back closes it; badge = requests). A Plan button (data-tz-plan) sits at the top next to Spin the wheel. The map-look button moved to a floating button bottom-right on the map. Undo: `backups/real-index-before-dock-friends.html`.
  - Friends screen redesigned like Facebook: title + search button, chips (Suggestions, Your friends, My code, Share link), big request cards with Confirm/Delete and mutual friends, suggestion cards with Add friend/Remove (S.hideSugg). DB migration `friends_mutual_faces`. Undo: `backups/real-index-before-friends-ui.html`.
  - In-app QR scanner (`K.scan`, module `Keni · scan` at the end): Friends → Scan chip, and "Scan a code" under My code. Reads #friend= / #t= / #ps= codes (BarcodeDetector, else jsQR 1.4.0 from jsdelivr). manifest.json now has handle_links + launch_handler so Android opens Keni links in the installed app. Camera not tested (blocked in the preview pane). Undo: `backups/real-index-before-scan.html`.
  - Also fixed: the Pasabit "When?" calendar styles (never copied from the prototype), and a tutorial crash on the "Plans" step (`rectOf`).
  - Tested in the preview with faked server calls.
  - Undo: `backups/real-index-before-profile.html`.
- Plan the user approved, in order: Messenger chat (built) → friends (add from a shared tropa/Pasabit or a friend link/QR; requests must be accepted; block + report) → bring Pasabit back with real group chats.

- 2026-10-22 Claude: **Get Keni link is LIVE**: https://keni-real.vercel.app/get (keni-real `f2679ce`; not yet tried on real phones).
  - New page `keni-real/get.html` (/get, optional ?from=Name) shows install steps for the visitor's phone: one-tap Install on Android Chrome, Share → Add to Home Screen on iPhone (⋯ menu on Safari 26), and "open in Safari/Chrome" inside Messenger/IG. A computer gets a QR.
  - In the app: "Invite friends to Keni" on your profile and a card at the bottom of Friends share /get?from=<first name>.
  - sw.js no longer handles /get. The preview server in .claude/launch.json serves /get.
  - Undo: delete get.html, and restore `backups/real-index-before-getkeni.html` and `backups/real-sw-before-get.js`.

- 2026-10-22 Claude: Profile chips (from, school, order, free time, favourite spot) use line icons, Instagram/TikTok use K.pvGlyph, and the private/tropa rows use line icons. LIVE (keni-real c03c23c). Undo: `backups/real-index-before-chip-icons.html`.

- 2026-10-22 Claude: Place categories use Keni line icons everywhere instead of emoji (`CAT[x].ic`, set in the data script; `c.emoji` stays only for plain text). This covers map pins, chips, place art, sheets, search, the wheel, and lists. Vibe and food-tag emoji are unchanged. LIVE (keni-real c03c23c). Undo: `backups/real-index-before-cat-icons.html`.

- 2026-10-22 Claude: Vibes, place tags (SUBS) and cravings also use line icons now. Their `.emoji` / `.e` field holds the icon and the old emoji is in `.txt`. The icon set is `TAGIC` / `window.keniTagIc` in the data script. Bursts can fly icons. LIVE (keni-real c03c23c). Undo: `backups/real-index-before-tag-icons.html`.

- 2026-10-23 Claude: Speed and bug fixes, LIVE (keni-real fcd0045). (1) Removed the hidden full-screen blur behind the map (`.mapbox.glass`), glass blur 22→16px, no blur-inside-blur. While the big map moves, `body.k-moving` turns off the blurs and pauses pin pulses. Card `rise` no longer animates blur. (2) Chats: the inbox only rebuilds when it changed; rows slide in once (`.ch-calm` after 700ms); smooth slides instead of the spring overshoot; keyboard fitting only updates on real changes. (3) Back in Chats/Activity switches the screen right away (`chSkipPop`), fixing being stuck after opening Activity from a notification. (4) Plan button icon centred. (5) The location card uses a line icon. Undo: `backups/real-index-before-perf.html`.

- 2026-10-23 Claude: The tropa chat Plan button (🗓️) and the Chats back arrows (←) now use line icons (`K.lic('cal')`, `K.lic('back')`). LIVE (keni-real fcd0045). Tropa invite check: the invite to YQAUIVV reached the DB (notification at 17:43 UTC), but the friend has no push device, so they were never pinged. It waits unseen in their Activity.

- 2026-10-23 Claude: **Push wording is LIVE (DB)**: migration `push_wording_name_first` changed 16 push texts to "Name" or "Name · group" with the message underneath, and no emoji. The old→new map is in `handoffs/notes/2026-10-23-push-wording.sql`; swap old/new to undo. iPhone adds "from Keni" itself.
- 2026-10-23 Claude: **Easier tropa invites**, LIVE (keni-real fcd0045). New DB fn `tropa_friend_status(code, secret)` (members only; friends in/invited, LIVE). The invite sheet is now "Add people": a friend list with Add / Invited / In states and search over 6, with the link below. Add to tropa from the Friends list row, a friend's profile, and the tropa chat header (`K.tsync.addFriend`, `data-ch="tadd"`). Invites sit on top of the Chats inbox (`.ch-inv`, dismiss stored in `S.invHide`). Join from an invite is one tap (`joinFlow(code, quick)` → `joinAs`); links skip the name step when signed in. Undo: `backups/real-index-before-tinvite.html`.

- 2026-10-23 Claude: **Your tropas hub**, LIVE (keni-real 4f26bf7). The Plan button (`data-tz-plan`) and the Tropa mode chip (`data-tz-open`, now labelled Switch) open `K.tropaHub`: one card per tropa (faces, people count) with Plan / Chat / Add / Manage, plus New tropa and Join with a code. Friends has a Tropas tab with the same cards. Manage opens the old My tropas sheet (👑 and 💬 removed). The tutorial Plan step accepts the hub. Undo: `backups/real-index-before-tropa-hub.html`.

- 2026-10-23 Claude: **Tropa photo**. The DB part is LIVE: migration `tropa_photo` adds `tropas.photo` (≤120k chars), `tropa_set_photo` (any member; adds a "X changed the tropa photo" sys line; max 3/min), allows `sys` messages, and returns the photo from tropa_get, chat_inbox, tropa_mine and tropa_invite (SQL in `handoffs/notes/2026-10-23-tropa-photo.sql`). The app part is LIVE (keni-real 4f26bf7). Manage (now titled with the tropa name) has a photo picker (256px JPEG). The photo shows on Your tropas cards, the Switch chip, Chats rows and header, and invite cards. Tapping the photo or name at the top of a tropa chat (`data-ch="tinfo"`) opens that tropa's Manage sheet. Undo: `backups/real-index-before-tropa-photo.html`.

- 2026-10-23 Claude: **Tropa info screen from the chat**, LIVE (keni-real 0c9e0cc). Tapping the top of a tropa chat now opens `K.tropaScreen.open('info')`: big photo (tap to change), name, people count + code, Add people, the people list, and Leave tropa (tap twice; closes the chat). No switcher bar. `K.tropa.remove` is now exported. Tested in preview. Undo: `backups/real-index-before-tinfo2.html`.

- 2026-10-23 Claude: **Poke cards use line icons**, LIVE (keni-real 0c9e0cc). Pokes (Tara / tonight / Gutom / Nasaan), their answers (G, Pass, Maybe, Hindi, Same, Busog, OTW, Here, 5 min) and Plan it now use `K.lic` icons (new: moon, bowl, car, help, smile; maps `PIC` / `AIC` in Chats). Emoji are still used for bursts and toasts. The inbox preview is text only. Undo: `backups/real-index-before-poke-icons.html`.

- 2026-10-23 Claude: **Tropa photo fix for iPhone + poke icon centring**, LIVE (keni-real 1de7689). The photo never reached the DB from the phone (YQAUIVV had no photo). Now the photo buttons are `<label for=tz-file>` pointing to one file input that stays on the page (no hidden input + .click()), the save runs from a document-level listener for the tropa that was open, and a sync for 20 s after a change can't put the old photo back (`t.photoAt`). The poke card icon box is centred (`.ch-pk .ch-pk-h > span`). Undo: `backups/real-index-before-photo-fix.html`.

- 2026-10-25 Claude: **Tropa nicknames**. DB LIVE: migration `tropa_nicknames` adds `tropa_members.nick` (≤20), `tropa_set_nick(code, secret, member, nick)` (any member, any member incl. self; sys line; max 5 sys/min), and the nickname in tropa_chat, tropa_msgs(2), tropa_msg_send (also push title), chat_inbox; tropa_member_json returns `nick` (name stays real so tropa_save never writes it). SQL: `handoffs/notes/2026-10-25-tropa-nick.sql`. App LIVE (keni-real a490577): pencil per person in tropa info (`K.tsync.setNick`, `saveNick`), nickname shown with the real name under it in info and Manage. Person menu (See profile / Remove friend / Report / Block) uses line icons (new: user, minus, flag, block, pen). Undo: `backups/real-index-before-nick.html`.

- 2026-10-25 Claude: **Emoji removed from 41 buttons**, LIVE (keni-real a490577). Text only, except a line icon on Send to a chat / Open the chat (chat), Suggest a place (pin), Share my friend link (link), Report (flag). Script: scratchpad strip-emoji.js. Undo: `backups/real-index-before-strip-emoji.html`.

- 2026-10-26 Claude: **Full nicknames in chat**, LIVE (keni-real 9140c09). Chats helper `nm(c, id, name)`: a nickname shows in full, a real name by its first word (names above messages in 3+ person chats, poke cards, toasts, active now, reactions). Undo: `backups/real-index-before-fullnick.html`.

- 2026-10-26 Claude: **Replies in chats**. DB LIVE: migration `message_replies` adds `reply_to` to tropa_messages, dm_messages, pasabit_messages; tropa_msg_send / dm_send / ps_send take optional `p_reply` (dropped + recreated, grants kept: tropa anon+auth, dm/ps auth only); tropa_chat / dm_chat / ps_chat return `reply` + quote `rq` (helpers tropa_rq / dm_rq / ps_rq, not callable by clients). SQL: `handoffs/notes/2026-10-26-replies.sql`. App LIVE (keni-real 9140c09): swipe a message (others → right, yours → left) or long-press → Reply; reply bar above the box (`.ch-rp`), quote on the sent message (`.ch-q`, tap jumps + highlights), 'Message removed' when the original is gone; chat redraws wait until a swipe ends. Undo: `backups/real-index-before-replies.html`.

- 2026-10-26 Claude: **Menu photos**. DB LIVE: migrations `menu_photos` + `menu_photos_select_own`: public bucket `menu-photos` (2 MB, jpeg/webp; upload/see/delete only in your own `<uid>/` folder, admins all), table `menu_photos` (no direct access), fns menu_photo_add (max 10 waiting), menu_photos_for, menu_photo_pending / menu_photo_review / menu_photo_unreview (admin; notifies kinds menu_ok / menu_no + push). SQL: `handoffs/notes/2026-10-26-menu-photos.sql`. App + admin LIVE (keni-real 9140c09): Menu tab box (`[data-mp]`, module 'Keni · menu photos', `K.menuPhotos`), Add menu photo (label for #mp-file, up to 5, shrunk to 1600px JPEG), swipe strip + full-screen viewer (swipe, pinch, double-tap), Activity rows; admin To do 'Menu photos waiting' with Approve/Reject (+undo; rejected file deleted after 9 s). Test slip: one preview test uploaded 2 blank photos under the owner's account for 1 min; both rows and files deleted, 0 left. Undo: `backups/real-index-before-menu-photos.html`, `backups/admin-before-menu-photos.html`.

## Next
- User: install it on a real Android phone (Install button) and a real iPhone (Safari → Share → Add to Home Screen). The card shows itself from the 2nd visit, or open it from Settings → Get the app.
- User: on a real phone, install Keni, turn on Settings → 🔔 Notifications, then have a 2nd phone start a vote or lock a pick in a shared tropa.
- Chat and pokes are built (see Now). Test them on 2 real phones after deploy.
- Still untested on two real phones: roles, live sync, voting, after-trip rating, streaks.
- Parked, don't build: tropa live location; Messenger share.
- Old open questions: Menu tab, a username notice on reports, redoing the report flow, nudging the spot pin.

## Log (newest first)
- 2026-10-26 Claude: Deployed replies, full nicknames in chat and menu photos (app + admin), and pushed both repos. Checked on the live site; not yet tried on real phones.
- 2026-10-26 Claude: Deployed tropa nicknames, person menu line icons and the button emoji removal, and pushed both repos. Checked on the live site; not yet tried on real phones.
- 2026-10-23 Claude: Deployed the iPhone tropa photo fix and the centred poke icon, and pushed both repos. Checked on the live site; the photo still needs a test on the iPhone.
- 2026-10-23 Claude: Deployed the tropa info screen and the poke card line icons, and pushed both repos. Checked on the live site; not yet tried on real phones.
- 2026-10-23 Claude: Deployed the Your tropas hub, tropa photos, and tropa settings from the chat header. Pushed both repos. Checked on the live site; not yet tried on real phones.
- 2026-10-23 Claude: Deployed the speed fixes, Chats back fix, easier tropa invites and the icon swaps, and pushed both repos. Checked on the live site; not yet tried on real phones.
- 2026-10-22 Claude: Deployed the line icons (categories, vibes, tags, cravings, profile chips) and pushed both repos. Checked on the live site; not yet tried on real phones.
- 2026-10-22 Claude: Deployed chat + pokes and the vote-photo fix. Checked on the live site; not yet tried on real phones.
- 2026-10-22 Claude: Deployed the strip removal and the no-text-selection map fix. Both are on the live site; not yet seen on the user's iPhone.
- 2026-10-21 Claude: Deployed the push client (sw.js push handler, the `K.push` module, Settings toggle, ask card). Note: Vercel's CDN took about 10s to show the new version.
- 2026-10-21 Claude: Push backend. Migrations `push_notifications` and `push_triggers_not_rpc` turned on pg_net and pg_cron, added the `push_*` tables and RPCs, the `push_on_tropa` and `push_on_join` triggers, and `tropa_save` now sets `keni.actor`. The edge function `push` source is in `supabase/functions/push/index.ts`. A rolled-back DB test passed. Undo the client with `backups/real-index-before-push.html`.
- 2026-10-21 Claude: Deployed the PWA to production (Vercel scope keni4). Undo: redeploy after restoring `backups/real-index-before-pwa.html`.
- 2026-10-21 Claude: Turned on live memory (this file). Backups copied to `backups/real-*-before-*.html`.
- 2026-10-21 Claude: PWA built (see Now). The preview server in `.claude/launch.json` now serves `/icons/`, `/manifest.json` and `/sw.js`. Undo: `backups/real-index-before-pwa.html`, delete the new files, set `vercel.json` back to `{"cleanUrls": true}`.
- 2026-10-21 Claude: After-trip rating + tropa streaks/badges are LIVE. DB: `place_ratings` table, plus `place_rate`, `place_scores` and `tropa_hangouts` (migration `place_ratings_and_hangouts`). Client: the `K.streaks` module at the end of `index.html`. Undo: `backups/real-index-before-ratings.html`.
- 2026-10-16 Claude: Silog 🍳 craving is LIVE (index + admin; DB `craving_ok` allow-list). Sisig's emoji is now 🥘. Undo: `backups/real-*-before-silog.html`.
