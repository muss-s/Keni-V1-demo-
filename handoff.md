# Keni: handoff for the next AI (updated 2026-10-31)

Read this file, then `handoffs/LIVE-STATE.md` (what is true right now), then the part of `KENI-DOCS.md` you need.

## 1. What Keni is
- A phone app (PWA) for finding places to eat and hang out in Angeles City (Pampanga, PH). You can also plan nights out with your friend group, which the app calls a **tropa**.
- Started as a school project. The owner now wants to **launch it for real**, so treat it like a product with real users.
- **Two copies:**
  - **Real app (the one you work on):** `keni-real/`. Live at https://keni-real.vercel.app.
  - **Demo `keni.html` (project root): FROZEN.** Never edit it. It is the old local-only prototype.

## 2. The owner (how to work with them)
- Has ADHD. Keep replies short, a few lines, plain words, **one question at a time**. They often work from their phone over Remote Control, so every final message must stand alone and end with one question that lists its choices, for example `(deploy / not yet)`.
- **Plan first** for any new feature. Say the plan in a few bullets and wait for "go".
- **"go" on a plan means build, not deploy.** Deploy only when they say "deploy" (or "go deploy"). For a plan with several parts, build every part first and deploy once at the end.
- **Every deploy also commits and pushes both repos** (see §6).
- In the UI and in replies, say **"tropa", never "crew"**.
- **No emoji as UI icons.** Use Keni's line icons (`K.lic(name)`, `icon()`, `K.pvGlyph`). If a line icon looks bad, use text only. Emoji are fine as *content*: bursts, toasts, a tropa's own emoji, the 👍 send button, 👋 pokes.
- Wants lively animations on new features. Warn them if something will be slow with the backend.
- Make things easy for users: native controls, search, pre-filled values, no arbitrary limits.
- When they ask for ideas: give about 5 short, numbered ideas and check they don't already exist (grep first; tropa streaks and owner claims already exist).

## 3. Hard rules (never break)
1. **Never put fake or test data in the real DB, and never create real tropas while testing.**
   - DB tests run in a DO block that ends with `raise exception 'DRYRUN OK ...'`, or in a transaction that rolls back.
   - Preview tests stub the network. The preview browser is **signed in to the owner's real account** and their real tropa (E44PARV).
   - Stub `K.sb.rpc`. For storage use `Object.defineProperty(K.sb, 'storage', {configurable: true, value: stub})`, because `K.sb.storage` is a getter that returns a new object each time. Remove the stub afterwards with `delete K.sb.storage`.
   - **Keep stubs in place until all async work is done.** A slow image resize once outlived the stub and uploaded 2 real photos; they were cleaned up.
   - Restore any localStorage you change.
2. **Keep secrets out of chat and git.**
   - `.mapbox-token` is gitignored and vercelignored.
   - The public Mapbox `pk.` token in the page is URL-restricted and allowed.
   - Before every push, grep the diff for `sk_`, `service_role` and `sk-ant`.
3. **Admin sign-in must never appear on the main sign-in page.**
4. **After every change**, update `handoffs/LIVE-STATE.md` (and `KENI-DOCS.md` for feature changes) before saying done.

## 4. The system
| Part | Where |
|---|---|
| App | `keni-real/index.html`, a single ~1.5 MB file of vanilla JS + CSS, about 13.7k lines, with about 49 inline `<script>` modules |
| Admin | `keni-real/admin.html` → /admin. Built for PC: sidebar with Overview, To do (new places, claims, reports, photos, promos; J/K/A/R keys), Places (every place, filters), Owners, People, Place reports, Promos, Tags. Under 900px the sidebar becomes tabs. `openPE(id)` is the full place editor (side panel, every field, Undo) |
| Install page | `keni-real/get.html` → /get?from=Name |
| PWA | `keni-real/sw.js`, `manifest.json`, `icons/`, `vercel.json` (headers for sw/manifest, cleanUrls) |
| Hosting | Vercel, scope `keni4`, project keni-real |
| Backend | Supabase project `wlxkdivnktxdbwbertjw` (Postgres, Auth, Storage, Realtime, pg_cron, pg_net, edge function `push`) |
| Edge function source | `supabase/functions/push/index.ts` (Web Push sender) |
| Repos | `keni-real/` → github.com/muss-s/keni-real. Project root (handoffs, docs, demo) → github.com/muss-s/Keni-V1-demo- |
| Libraries (CDN) | supabase-js 2.45.4, mapbox-gl 3.15.0 (main map only), leaflet 1.9.4 + OSM tiles (small maps), jsQR 1.4.0 (QR fallback) |
| Sign-in | Supabase email: magic link/OTP (`signInWithOtp`) and password. An account is required to use the app. |

**How index.html is built**
- Each feature is an IIFE in its own `<script>/* Keni · <name> ... */` block. The blocks share `window.KeniCore` (called `K`): `K.S` (state), `K.sb` (Supabase client), `K.esc`, `K.toast(html, fn?, label?)`, `K.openDetail(id, tab)`, `K.closeModal`, `K.openLogin`, `K.VBY` (places by id), `K.lic(name)` (icons), `K.hooks`.
- Find a module with `grep -n "<script>/\* Keni · "`.
- Main modules: places from the database, Plan hub, Studio (owner side), accounts, tropa sync (`K.tsync`), wheel/swheel/swipe (group choosing), friends + messages, reviews + photos, Pasabit (`ps_*`), My tropas (`K.tropaScreen`, `K.tropaHub`), notifications/push (`K.push`), Chats (`K.tchat`), profile pages, scan (`K.scan`), streaks (`K.streaks`), photos from people (`K.menuPhotos`).
- The icon set is the `const P = {...}` map in the "Keni · line icons" script. Add new names there.
- Place categories, vibes and tags use line icons (`CAT[x].ic`, `TAGIC` / `window.keniTagIc`); the old emoji are kept in `.txt`.

**Database (public schema, RLS on everywhere; most writes go through `security definer` RPCs)**
- `places` (1,467 rows; **since 2026-10-30 all 1,452 Keni-added rows are `hidden`**, only places added by people show; `photo` = cover URL or `images/real/...`; `more_photos` jsonb; `level` full/basic; `hours` [open, close] with close > 24 = after midnight, `days` {weekday: [o,c] or null} overrides, `off_days` (0 = Sunday); `status` pending/approved/rejected; `added_by`). RLS: anyone reads approved public non-hidden rows; admins read and update everything. `profiles`, `profile_extras`, `admins` (1 row, the owner).
- Owners: `place_claims`, `place_edits`, `place_posts`, `place_post_reports`, `place_hits` (views/saves per phone/day). Admin RPCs: `admin_overview`, `owners_admin`, `owner_remove/restore`, `people_admin`, `people_reports_admin`, `report_handle`, `pasabit_admin_cancel`.
- Tropas: `tropas`, `tropa_members` (with `nick`), `tropa_messages` (with `reply_to`), `tropa_poke_answers`, `tropa_msg_reactions`. RPCs `tropa_*` (get/save/join/create/leave/invite/set_photo/set_nick/msg_send/chat/...).
- Social: `friendships`, `blocks`, `user_reports`, `dms`, `dm_messages`, `dm_reads`, `dm_reactions`, `chat_clears`, `notifications` (Activity feed; `notify()` helper).
- Pasabit (public "tag along" plans): `pasabits`, `pasabit_members`, `pasabit_messages`, `pasabit_reactions`, `pasabit_reports`. pg_cron job `keni-pasabit-reminders`.
- Community: `reports`, `craving_votes`, `place_ratings`, `menu_photos` (`kind` = menu|place; bucket `menu-photos`, public, 2 MB).
- Push: `push_config`, `push_subs`, `push_sub_members`, `push_queue`, `push_sent`. `push_enqueue_user(user, title, body, tag, url)`; **url must not be null**.
- SQL for recent migrations is in `handoffs/notes/*.sql`.

## 5. How to make changes
- **Patching index.html:**
  - Back up first: `backups/real-index-before-<topic>.html` (admin: `backups/admin-before-<topic>.html`).
  - Write a Node script in the scratchpad (with the Write tool, not a bash heredoc, which breaks backslashes and quotes). It uses `rep(a, b)`, which throws unless the anchor matches exactly once.
  - Then syntax-check every inline script with `new Function(...)`; expect 0 errors.
- **DB changes:**
  - Use `apply_migration` with a clear name, and save the SQL to `handoffs/notes/<date>-<topic>.sql`.
  - For small edits to big functions, use a DO block: `replace(pg_get_functiondef(...), old, new)` and raise if `old` isn't found.
  - When you change a function's signature: drop it, create it, then `revoke ... from public, anon, authenticated` and grant only what's needed. Supabase auto-grants anon on new functions.
  - End with `notify pgrst, 'reload schema'`.
  - Test with a DRYRUN DO block, and act as a user with `set_config('request.jwt.claims', json_build_object('sub', <uid>, 'role', 'authenticated')::text, true)`.
- **iPhone file pickers:** use a `<label for="id">` pointing at one persistent off-screen `<input type=file class="tz-file">`, with a document-level `change` listener. A hidden input + `.click()` does not work on iPhone.
- **Preview:**
  - Use `preview_start` with name `keni-real` (port 5176; config in `.claude/launch.json`; serves /, /get, /admin, /images, /icons, /sw.js, /manifest.json).
  - Resize to 430x932 for phone testing, and set it back to desktop when done.
  - Run `KeniCore.tour.end()` if the tutorial appears.
  - The preview freezes CSS animation timelines, so use transform-only entrance animations.
- **Deploy (only when told):**
  ```bash
  cd keni-real && npx --yes vercel@latest deploy --prod --yes --scope keni4
  ```
  - Verify by fetching the live page via `ctx_execute` (curl is blocked) and grepping for the new code. The CDN can take about 10 s to update.
  - Then commit and push keni-real and the root repo. Commit trailer: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
  - Add a Log line in LIVE-STATE.

## 6. Where things stand (2026-10-31)
- **Latest (2026-10-28 to 10-30), all live:**
  - Owner side: real claims, Studio (edit listing, reports, plan card shown only, Your numbers), promos and events.
  - PC admin and the full place editor; the Places tab lists every place.
  - The final school pitch is done (deck `pitch/Keni-Startup-Pitch-fixed.pdf`; users free, venues pay).
  - The owner then asked to hide every place Keni added, so only 5 approved places from people show. Undo SQL is in `handoffs/notes/2026-10-30-hide-keni-places.md`.
- **The owner's mood:** after the pitch they felt lost (no testers, and the app runs on its users). I suggested a 2-week test with 3 friend groups; they chose "just the seeding for now". Be encouraging and concrete; don't push big plans.
- **Seeding:** `seeding/auf-30.csv` has 30 small pins near AUF for the owner to fill in, but those pins are hidden now. Ask how they want to seed before using it.
- **Live (older):** everything in `handoffs/LOG-ARCHIVE.md` up to menu photos (keni-real commit 9140c09). That includes PWA + push, tropas (planning, voting, live sync, roles, chat, pokes as polls, photo, nicknames, info screen), friends, DMs, Activity, Pasabit, profiles, QR scan, replies in chats, menu photos with admin review, after-trip ratings, streaks/badges, and line icons everywhere.
- **Live since 2026-10-27 (not tried on real phones):** place photos + auto cover.
  - Photos tab "From people" with Add photos.
  - Overview row of the newest 4 photos.
  - "Share it with everyone" for photos saved on the phone.
  - Admin labels Place/Menu photo.
  - The first approved place photo becomes the cover if the place has none.
  - The DB side is already live, including a fix: approving a photo used to crash for users with push turned on (null push url).
  - Backups: `real-index-before-place-photos.html`, `real-index-before-auto-cover.html`, `admin-before-place-photos.html`.
- **Never tested on real phones:** almost everything, especially two-phone tropa sync/voting, push on iPhone, the QR camera, and the iPhone photo picker fixes. This is the biggest risk.
- **Parked (don't build unless asked):** live tropa location sharing (a PWA can only share while the app is open), and Messenger share.
- **Open, needs details from the owner:** "pins disappearing" on the map.
- **Last ideas offered (none picked yet):** open-now alerts, price checks, split the bill, "where we've been" tropa map, late-night finder.
- **Not built:** paid plans (the Studio plan card only shows a toast), menu-from-photo AI (discussed; the owner chose photos only).

## 7. Gotchas learned the hard way
- `.ch-m` has `overflow:hidden`; swipe UI needed `.ch-sw{overflow:visible}`. Chat `draw()` must wait while `thread` has `ch-swiping`.
- A CSS rule with higher specificity can silently win; check computed styles with `javascript_tool`.
- Grid children stretch: the photo viewer had to use flex with `min-width:0`.
- Storage `remove()` silently removes 0 files without a **select** policy.
- Recreated functions get anon execute by default; always revoke explicitly.
- `places` has a `places_touch` trigger (updated_at). The app re-downloads places when the row count or newest updated_at changes, so any update reaches phones on next open.
- Supabase returns at most 1,000 rows per request: page with `.range()`. A hidden `.limit(100)` in the admin Places tab once made user-added places look missing.
- **Admin preview tests:** fake the whole backend. Navigate the tab to `/manifest.json`, put a fake session in localStorage (`sb-wlxkdivnktxdbwbertjw-auth-token`), fetch `/admin.html`, inject a `<script>` that wraps `window.fetch` (in an IIFE, or a second write fails with "already declared"), then `document.write` it. Remove the fake token afterwards. `people_reports_admin` must return `{users:[],pasabits:[]}`.
- Screenshots in a hidden preview pane can catch animations half done (panels look see-through). Check with `elementFromPoint` before "fixing" it.
- Carto map tiles now need an API key; use `tile.openstreetmap.org` with attribution, and a `L.divIcon` pin (Leaflet's default marker image doesn't load from cdnjs).
- Bash heredocs with quotes or `’` can fail; write patch scripts with the Write tool.
- The owner's iPhone is the main test device. Safari quirks (file input, sheets stuck at the bottom, text selection on long press) have each needed specific fixes; see LIVE-STATE.

## 8. Files to know
- `CLAUDE.md`: two lines pointing here and to LIVE-STATE.
- `handoffs/LIVE-STATE.md`: Now / Next / Log, kept under about 150 lines and 15KB.
- `handoffs/LOG-ARCHIVE.md`: older LIVE-STATE entries with full details and undo paths.
- `seeding/auf-30.csv`: AUF seeding sheet. `pitch/`: the pitch deck and its HTML source.
- `handoffs/notes/`: SQL and long details per topic.
- `KENI-DOCS.md`: what every feature does, for people (§17 is the real version).
- `backups/`: about 86 before-change copies, for undo.
- Transcript of the latest Claude chat: `C:\Users\merci\.claude\projects\C--Users-merci-OneDrive-Documents-Projects-Keni-app\4873caa1-6139-47db-bfed-ed172b4cb55a.jsonl` (grep it for old details, don't read it whole).
