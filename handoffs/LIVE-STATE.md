# Keni: live state
Read this first. Background, rules and code anchors are in `../HANDOFF.md`. Older entries, with full details and undo paths, are in `LOG-ARCHIVE.md`.

## Now
- 2026-10-30 Claude: **Only places added by people show.** At the user's request, all 1,452 Keni-added places (18 full listings + 1,434 small pins, `added_by is null`) are `hidden = true`. Hidden, not deleted. The live app shows 5 approved places: Royal Brews Cafe, Hakone - Infinity, Pour Over - AUF, Doze, Totobits. Oh Chicken and COFFEE LAB are waiting for approval in /admin. Undo SQL (keeps the 7 that were already hidden): [notes/2026-10-30-hide-keni-places.md](notes/2026-10-30-hide-keni-places.md).
- 2026-10-30 Claude: **Full admin place editor, LIVE** (keni-real 62ec421). A side panel (`openPE` in keni-real/admin.html) edits every field of a place: pin size, status, hidden, name, all kinds, symbol, area, address, pin on a Leaflet + OSM map, price, hours per day, hours note, description, vibes, perks, cravings, 5 contacts, photos (upload, cover, reorder, remove). It opens from Places rows, "Edit everything" on new places and "Fix the place" on reports. Save has Undo. The Places tab loads every place (it was capped at 100, which hid user-added places) and has a Full listings filter. Tested only with fake data; a real save and a real photo upload haven't been tried. Undo: `backups/admin-before-full-editor.html`.
- Live and never tried on real phones: almost everything (PWA install, push, tropa sync and voting, chats, Pasabit, QR scan, owner claims, Studio, promos, place photos). This is the biggest risk.
- Live, never used with real data: the PC admin (Overview, To do with J/K/A/R keys, Owners, People), owner claims, promos and events, Your numbers.

## Next
- User: approve or fix Oh Chicken and COFFEE LAB in /admin (Edit everything → Approve).
- User: try one real save and one real photo upload in the admin editor.
- Seeding: `seeding/auf-30.csv` lists 30 AUF small pins to fill in, but they are all hidden now. Ask before using it: un-hide those rows, or seed by adding places as a person.
- User: install Keni on a real Android phone and a real iPhone, turn on notifications, then test a tropa vote with a 2nd phone.
- User: try the owner side on a real phone (claim, approve in /admin, edit the listing, post a promo).
- Offered, not picked: a 2-week test with 3 friend groups (the user said "just the seeding for now").
- Parked, don't build: tropa live location; Messenger share.

## Log (newest first)
- 2026-10-31 Claude: Handoff refresh. Old Now/Next/Log moved to `LOG-ARCHIVE.md`; `HANDOFF.md` updated.
- 2026-10-30 Claude: Hid all 1,452 Keni-added places (DB only, no deploy). Pushed notes (root 5ab375c).
- 2026-10-30 Claude: Deployed the full admin place editor + all-places list (keni-real 62ec421, root 12c5da1). Checked on the live site.
- 2026-10-28 Claude: Deployed "Edit details" on new-place cards (keni-real 1c1f606). Replaced on 2026-10-30 by the full editor.
- 2026-10-29 Claude: Deployed full-listing admin cards (keni-real 3873203), and the PC admin, Your numbers, plan card and "I own this place" fix (keni-real 40a130b). DB: migrations `admin_pc`, `place_stats`.
- 2026-10-29 Claude: Pitch done; demo claim undone (0 claims, 0 posts, 0 hits). Fixed deck: `pitch/Keni-Startup-Pitch-fixed.pdf`.
- Older: see `LOG-ARCHIVE.md`.
