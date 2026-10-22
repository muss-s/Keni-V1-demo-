# Keni — Handoff (2026-10-16)

## What this is
- **Real app:** `keni-real/index.html` (single-file vanilla JS) + `keni-real/admin.html`
- **Live:** https://keni-real.vercel.app (Vercel scope `keni4`)
- **DB:** Supabase project `wlxkdivnktxdbwbertjw`
- **Demo `keni.html` (root) is FROZEN.** Don't touch it.
- **Feature docs:** `KENI-DOCS.md`. Update it with every feature.

## Working with the user
- Short replies (ADHD), one question at a time.
- Plan first, then wait for "go" on new features.
- Deploy **only** when they say go or deploy.
- Lively animations. Say "tropa", never "crew".
- Never put fake or test data in the real DB, and never create real tropas while testing.
- Keep secrets out of chat and git. `.mapbox-token` is gitignored and vercelignored. The public pk token in the page is URL-restricted and allowed.
- Admin sign-in must not appear on the main sign-in page.

## How to work
- **Patch:** write a node script in the scratchpad that uses `rep(a, b)`, which throws if the anchor is missing or appears twice. Back up `index.html` first. Use the Write tool to write scripts; bash heredocs break on quoting.
- **Syntax check:** run `new Function` on each `<script>` block.
- **Preview:**
  - Use the launch config `keni-real` on port 5176.
  - Run `KeniCore.tour.end()` first.
  - Stub roles with `K.tsync.role = () => window.__role`.
  - Test with the mobile preset, then reset to desktop.
  - Use only local data, and clean it up.
- **Deploy:**
  ```bash
  cd keni-real && npx --yes vercel@latest deploy --prod --yes --scope keni4
  ```
- **Verify live:** fetch the page through ctx_execute (curl is blocked) and grep for the new code.
- The preview's animation timeline is frozen, so use transform-only entrance animations.

## Shipped this session (all live)
- **Account**
  - Reset Keni removed.
  - Sign out returns to the welcome page (`K.signOutToWelcome`).
- **Maps**
  - Mapbox GL loads only for the main map.
  - Small maps use free OSM tiles (dark-mode invert filter).
- **Layout fixes**
  - The Tropa page top bar shows only the logo.
  - iOS sheets no longer get stuck at the bottom (the `nudge` scroll fix).
- **Places:** pending places are hidden from others (RLS plus client filter) and show "⏳ Waiting for approval" to the person who added them.
- **Planning and sync**
  - Planning redo: dock button, tz chip, invite card, trip filter.
  - Live sync: Realtime broadcast `tropa-<code>` 'poke', with 4s / 15s polling as a fallback.
- **Roles**
  - The owner is the only one who can remove people.
  - Members answer, then tap "I'm set".
  - The owner waits for everyone, then plans.
  - If the owner isn't going, the first person to press "Plan it" plans.
  - These rules are enforced in the DB (`tropa_save`).
- **Removing people**
  - Each person has a ✕ (tap twice to confirm).
  - Removals queue in `R.drop`, so a refresh can't bring a removed person back.
- **No hand-added friends:** they were purged client-side, and a DB check now requires an account or a secret.
- **Voting**
  - The planner picks 1, 2 or 5 minutes and starts the vote on the top 4 places.
  - Everyone votes live while a countdown ring runs.
  - The vote ends at zero, or as soon as everyone has voted.
  - Most votes wins. A tie goes to Keni's higher-ranked place.
  - The winner auto-locks.

## Not verified
- Roles, live sync and voting haven't been tested on **two real phones**. Do that first.

## Open questions (ask one at a time)
1. Menu tab: hide it, or add real menus?
2. Show a username notice on the report sheet?
3. Redo the report flow?
4. Nudge the spot pin so it isn't on top of the location pin?

## Key code anchors (index.html)
- `K.tsync = { invite, pickerHTML, tick, ensureRemote, codeSheet, leave, role, claim }`
- `K.tropaScreen = { open, paint }`
- Plan stages: crew → tonight → rules → match/reveal/vote → locked (`ui.bkStage`)
- Vote: `VOTE_MINS`, `vTally`, `voteHTML`, `lockIn(id, extra)`
- DB RPCs: `tropa_get`, `tropa_save`, `tropa_join`, `tropa_create`, `tropa_leave`, `tropa_planner`
