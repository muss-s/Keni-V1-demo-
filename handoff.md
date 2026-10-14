# Keni handoff

Written 2026-10-14. This is everything a new session needs to pick up Keni without the earlier conversation.

## What Keni is

Keni is a web app for finding places and planning outings in Angeles City, Pampanga. The whole app is one file, `keni.html` (about 8.4 MB, plain JavaScript, no build step, no backend). Everything a user does is saved on their own device.

- Live site: https://keni-update.vercel.app
- **The live site is behind the local file.** Everything under "Changed since the last deploy" below is local only.

## Where the project stands

- It is a **school group project** first. The owner may take it further as a real startup afterwards, so say which parts are demo-only and which would work for real users.
- The class deliverable is a **Simplified Validation Board** (Customer Segment, Problem, Solution, Experiment, Success Metric, Result, Action) and a 5-minute, 7-slide presentation.
- The group interviewed **20 people** (students aged 20 to 24, plus one working adult). They did **not** interview business owners.
- The group has said the target is **small business owners**. The agreed way to square that with the interviews: students are the users, owners are who it serves and who would pay. Every place is listed; small businesses get the spotlight.
- A reviewer (Laurence) said the features are easy to copy, that everyone having to download the app is a hole, and that a majority-rules group pick is no better than a Messenger poll. The Tropa mode changes below are the answer to the last point.

### Interview numbers (from the group's own summary)

Biggest pains, out of the 18 interviewees with pains recorded:

| Pain | Count | Share |
|---|---|---|
| Place is full, closed or crowded | 13 | 72% |
| Outdated or missing shop info | 12 | 67% |
| Budget or price unclear | 10 | 56% |
| Too many options, hard to decide as a group | 9 | 50% |
| Location, nearby or transport | 7 | 39% |
| Trusting reviews | 4 | 22% |
| Amenities | 2 | 11% |

How they decide today, out of 20: nearby and cheap 12, ask friends or family 9, Google Maps 9, social media 8, go elsewhere or wait 8, check onsite 3. All 20 said they would use Keni. That 100% is probably politeness, and the deck says so.

## Files

| Path | What it is |
|---|---|
| `keni.html` | The app. The only up-to-date copy. Not a git repo. |
| `backups/` | A copy of `keni.html` before each feature. Latest: `keni-before-remove-movies.html`. |
| `presentation/Keni-Validation-Results.pptx` | The 7-slide deck, with a script in the speaker notes. |
| `presentation/Keni-Simplified-Validation-Board.pptx` | The one-page board in the teacher's layout. |
| `photos/<place>/place.*` | Real photos the owner sent for places. `photos/_pending.txt` lists ones not added yet. |
| `logo/` | Logo and app icon files. |
| `mapbox/keni-night-style.json` | The custom map style. |
| `data/` | The OpenStreetMap landmark list and the script that built it. |
| `.claude/launch.json` | Preview servers: `keni` on port 5173, `keni-files` on port 5175. Each picks another free port if its own is taken (saved data is separate per port). |

## Changed since the last deploy (local only)

All of this is in Tropa mode. It was tested in the preview and is **not deployed**.

1. **Three questions instead of taste.** Who's going, then "Anong trip ngayon?" (each person's trip and budget), then "Where, and how far?" (pin plus Walking, Short ride or Anywhere, which replaced the slider).
2. **Usual answers are pre-selected.** Budget comes from the profile. The trip is pre-selected only once the user has tapped "Anong trip mo?" on the map enough for Keni to know their usual.
3. **Budget is a preference, not a group limit.** The owner asked to scrap "the lowest budget sets the limit for everyone". A place over someone's budget now counts against that person only.
4. **Taking turns.** When a pick is locked, whoever did not get their way is owed one. Next time, places that give them their trip are ranked first. Getting your way clears it. Unlocking a pick undoes it.
5. In the demo you answer for your friends. Each friend answering on their own phone needs a backend.

Also local only, outside Tropa mode:

6. **Movies is switched off for now** (focus on small businesses). The Movies kind and SM Clark Cinema are commented out in `keni.html`, not deleted: search for `switched off`. "Laro o sine" in Plan my night is now "Laro". Saved data that still mentions movies is cleaned on load. The cinema labels from OpenStreetMap still show on the map as landmarks.
7. In the Tropa pick, "vetoed" now reads "voted" (the counter in the matching animation and the "Voted by someone" list). The other veto wording ("VETO" stamp, "vetoes", "Hard no's (veto)") is unchanged.

Known limits of the new flow:
- A person whose trip is blocked by someone else's hard no can stay owed for a long time (in the demo tropa this happens to Jun and Carlo).
- The top pick can be a place that is closed unless "Open now" is switched on.

## Open questions waiting on the owner

- Should "Open now" be on by default in Tropa mode? (A closed place was the top pain in the interviews.)
- The **Success Metric** row on the board and on slide 2 is still a "TO FILL IN" placeholder. The group set no pass mark before interviewing. Suggested: "60% of respondents would use the app", like the teacher's sample.
- Slide 1 of the deck needs three interview photos.
- "Add a place": the owner wants it removed. It has seven entry points. Unanswered: remove all, or keep the one for business owners?
- Remove "I'm here" from the hold-the-map wheel?
- Clark CDC (outdoors) photo is saved in `photos/clark-cdc/` and waiting. Do not add it until the owner says their list of places is finished.

## Parked ideas (planned, not approved or not built)

- Review reactions (Accurate, Not accurate) and comments on reviews.
- A "See what's showing" button for SM Clark Cinema. There is no public showtimes feed, so it would open SM Cinema's own page.
- Price and "how full" on map pins, plus a budget control on the main map.
- A group link so friends can join without downloading (needs a backend).
- "Been here, did you like it?" was dropped: tastes change, the same weakness as taste itself.
- TikTok creator features, "Tropa deals" for owners, "Ask Keni" AI (needs a backend; an AI key must never sit in the app file).

## How the owner likes to work

- They are a student, not a programmer, and have ADHD. Keep replies short, in plain language, and ask **one question at a time**.
- For a new feature or redesign, **say the plan first and wait for a go-ahead**. Small direct tweaks can be done at once. Approval often comes as "go" or as their own pasted bullets.
- **Deploy only when asked.**
- New features should have short, lively animations. Warn if something will be slow once there is a backend.
- Make things easier for the user: native controls, search, pre-filled values, no arbitrary caps.
- Adding places: they send a name and photo one at a time. Save each and reply only "done". Do the lookups and edits in one batch after they say the list is finished.
- **Nothing invented is shown on a real business**: no made-up photo, rating, reviews, menu, contacts or tag counts. Unknown hours say "Hours not listed".
- They test on an iPhone at the live URL, and also tap around in the desktop preview pane.

## How to edit and test

- **Editing:** the file is too large to edit by hand comfortably. Earlier sessions used a small script that applies exact find-and-replace pairs and refuses unless each "find" matches exactly once, then checked every `<script>` block still parses (29 blocks, 0 bad). Those helper scripts lived in a temporary folder and may be gone; they are easy to rewrite. Copy `keni.html` into `backups/` before each feature.
- **Structure:** the core exposes `window.KeniCore` (state `S`, saved under the `keni.v1` key in the browser's local storage). Features are `<style>` plus `<script>` blocks appended before `</body>`. Tropa mode is in the "Plan hub" script (search for `BARKADA MODE`).
- **Testing:** use the `keni` preview server (port 5173). Run tests in a **separate background tab** and close it after, because the owner uses the main tab and all tabs share saved data. Save and restore `keni.v1` around any test that changes state. The owner's saved state is currently at the welcome screen (not signed in), so a test has to mark it done and reload, then restore.
- Animations freeze in a hidden tab, and anything driven by the browser's animation frame timer does not run there (the Tropa "matching" animation, for example). Jump stages directly instead.
- **Deploying:** copy `keni.html` to a folder as `index.html` and run `npx --yes vercel@latest deploy --prod --yes --scope keni4` from that folder (it needs the project link from the earlier deploy folder, or re-link to the `keni-update` project). Then fetch the live URL and check for a string that only the new version has.

## Things only a real phone can confirm

- How the map fly-in, pin bounce and the new chip animations feel.
- The native time picker in Pasabit, long-pressing the map, and picking profile photos.
- The two PowerPoint files have never been opened in PowerPoint (none is installed here). Flip through them before presenting.

## Security notes

- The Mapbox token inside the app is a public token (it starts with `pk.`) and is not yet locked to the Keni URL. Never put a token starting with `sk.` in the app.
- Social sign-in (Google, Facebook, Instagram, TikTok) is simulated.
