# Keni: live state
Read this first. Background, rules and code anchors are in `../HANDOFF.md`.

## Now
- 2026-10-21 Claude: **PWA is LIVE** on keni-real.vercel.app. Manifest, sw.js, icons and headers are checked. It hasn't been installed on a real phone yet.
- 2026-10-22 Claude: GitHub is up to date: keni-real `730e174`. Push with every deploy.

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

## Next
- User: install it on a real Android phone (Install button) and a real iPhone (Safari → Share → Add to Home Screen). The card shows itself from the 2nd visit, or open it from Settings → Get the app.
- User: on a real phone, install Keni, turn on Settings → 🔔 Notifications, then have a 2nd phone start a vote or lock a pick in a shared tropa.
- Chat and pokes are built (see Now). Test them on 2 real phones after deploy.
- Still untested on two real phones: roles, live sync, voting, after-trip rating, streaks.
- Parked, don't build: tropa live location; Messenger share.
- Old open questions: Menu tab, a username notice on reports, redoing the report flow, nudging the spot pin.

## Log (newest first)
- 2026-10-22 Claude: Deployed chat + pokes and the vote-photo fix. Checked on the live site; not yet tried on real phones.
- 2026-10-22 Claude: Deployed the strip removal and the no-text-selection map fix. Both are on the live site; not yet seen on the user's iPhone.
- 2026-10-21 Claude: Deployed the push client (sw.js push handler, the `K.push` module, Settings toggle, ask card). Note: Vercel's CDN took about 10s to show the new version.
- 2026-10-21 Claude: Push backend. Migrations `push_notifications` and `push_triggers_not_rpc` turned on pg_net and pg_cron, added the `push_*` tables and RPCs, the `push_on_tropa` and `push_on_join` triggers, and `tropa_save` now sets `keni.actor`. The edge function `push` source is in `supabase/functions/push/index.ts`. A rolled-back DB test passed. Undo the client with `backups/real-index-before-push.html`.
- 2026-10-21 Claude: Deployed the PWA to production (Vercel scope keni4). Undo: redeploy after restoring `backups/real-index-before-pwa.html`.
- 2026-10-21 Claude: Turned on live memory (this file). Backups copied to `backups/real-*-before-*.html`.
- 2026-10-21 Claude: PWA built (see Now). The preview server in `.claude/launch.json` now serves `/icons/`, `/manifest.json` and `/sw.js`. Undo: `backups/real-index-before-pwa.html`, delete the new files, set `vercel.json` back to `{"cleanUrls": true}`.
- 2026-10-21 Claude: After-trip rating + tropa streaks/badges are LIVE. DB: `place_ratings` table, plus `place_rate`, `place_scores` and `tropa_hangouts` (migration `place_ratings_and_hangouts`). Client: the `K.streaks` module at the end of `index.html`. Undo: `backups/real-index-before-ratings.html`.
- 2026-10-16 Claude: Silog 🍳 craving is LIVE (index + admin; DB `craving_ok` allow-list). Sisig's emoji is now 🥘. Undo: `backups/real-*-before-silog.html`.
