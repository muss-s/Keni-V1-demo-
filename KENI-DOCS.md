# Keni: what is in the app

Last updated 2026-10-14. This describes `keni.html` as it is on that date. This is also what is live at https://keni-update.vercel.app.

Keni helps people in Angeles City, Pampanga find a place and decide where to go, alone or as a group. The whole app is one file, `keni.html`. There is no server yet, so everything a person does is saved in their own browser.

**How to read this file**

- **Demo** means it works on one device with made-up people or numbers. It needs a backend before real users can share it.
- **Real** means the information shown is true (a real place, real hours, a real menu).
- "Find it in the code" gives words to search for in `keni.html`. Line numbers change with every edit, so search for the words instead.

---

## 1. The screens

| Screen | How to get there | What it is for |
|---|---|---|
| Welcome | First visit | The animated "keni" wordmark and the sign-in buttons |
| Map | Opens by default; middle button of the bottom bar | The home page. Pins for places and Pasabits |
| Explore | Bottom bar | The same places as a list of cards, with kind chips |
| Saved | Bottom bar | Places you tapped the heart on |
| Chats | Circle on the bottom bar | Messages and friends |
| Place sheet | Tap any pin or card | Everything about one place |
| Tropa mode | People button in the top bar | Pick a place as a group |
| Profile | Your photo in the top bar | Your details, lists and settings |
| Studio | Bottom bar, owners only | The owner's dashboard for their place |

The top bar has: the Keni logo (goes home), search, Spin the wheel, Tropa mode, your profile, and a button that changes how the map looks.

---

## 2. Signing in

### Welcome page
- Buttons: Google, Facebook, Instagram, TikTok, **I own a place**, and Skip for now.
- **Demo.** Sign-in is simulated. No real account is contacted and no password is asked for. The explorer gets a placeholder profile named Juan Dela Cruz.
- After a first sign-up, the tutorial starts (section 12).

### I own a place
- Opens the owner sign-in. The owner searches for their place and claims it, then lands in the Studio.
- **Demo.** Any 4-digit code passes the "verify" step. Real ownership checks need a backend.
- There are also demo owner logins for presenting (for example Lia Navarro for Rio St. Coffee).

### Request a listing
- For an owner whose place is not on the map. It is reached from "Can't find your place?" in the owner sign-in.
- The form asks for the name, kind, area, an address or landmark, and a page or number to check. A photo is optional, and the owner can ask for Keni's set-up service (section 9).
- **Nothing goes on the map.** The request is saved as "Waiting for a check" and shows in the owner's profile, with a Cancel button.
- **Demo.** The request stays on the device. A real launch would send it to the Keni team.
- Regular users can no longer add a place. Every old "Add a place" button was removed on 2026-10-14.

Find it in the code: `wm-own`, `claimFlow`, `reqStep`, `S.biz.requests`.

---

## 3. The map

- **Pins** for every listed place, plus Pasabit pins. Tapping a pin opens the place sheet.
- **"Anong trip mo?" row:** Kape, Gutom, Tambay, Gala, Inom. One tap filters the pins; a second tap clears it. Keni saves the day and time of each tap and learns your usual one, which then shows first with a "usual" mark.
- **"Anong vibe?" row:** Cozy, Barkada, Quiet, Aesthetic, Retro, Outdoorsy, and so on. It only offers vibes that a place in view really has.
- **Filters panel:** Places / Pasabits / Both, kind of place, Open now, price, sort (Best match, Top rated, Nearest), amenities (Wi-Fi, Outlets, Aircon, Parking, CR, 24/7, Quiet now) and area.
- **Count bar:** "18 places", Near me, Show all.
- **Your location** (updated 2026-10-14): whenever the phone's location is off, the map shows a card, "Turn on your location", with "Use my location" or "Not now". "Not now" only hides it until the app is opened again. If the phone has blocked location for Keni, the card instead says "Location is off for Keni" and explains how to turn it on (on iPhone: Settings → Privacy & Security → Location Services → Safari Websites → While Using the App), with "Try again". "Near me" also asks the phone for your location if it doesn't have a recent one (less than 5 minutes old), then flies the map to you. After that, every distance says "km from you". Coming back to the app after 5 minutes quietly updates it. The location stays on the phone and is used only for distances; Privacy has a "Stop" button. If location is blocked, Keni says how to allow it, and distances fall back to the area you picked.
- **Hold the map:** press and hold an empty spot for a ring of three actions: Pasabit here, Tropa meet here, What's near.
- **Map look:** Keni Night, Light or Satellite.
- **Map tiles** come from the owner's Mapbox account. If Mapbox refuses, the app falls back to OpenStreetMap by itself.
- **Basic places:** small coloured dots for 1,441 restaurants, cafés, sports places, parks and KTV from OpenStreetMap (section 11). Bars are left out for now. They only appear once you zoom in, and only those in view, so the map stays smooth. The count bar then says "+ 264 basic", or "zoom in for more" when zoomed out.
- **Landmarks:** about 6,200 named spots from OpenStreetMap (malls, schools, churches, cinemas) are built in for search and orientation. Food, drink, sports and park spots among them are the basic places above.

Find it in the code: `TRIPS`, `vibeRow`, `renderFilters`, `getList`, `hold the map`, `KENI_SPOTS`.

---

## 4. Search

- A list drops under the search bar as you type.
- It finds places, and the kinds, vibes and tags that places really have.
- An exact place name opens that place. A vibe or tag filters the map to the places that have it.
- It also understands local words, for example "kape" for café and "inom" for drinking.

Find it in the code: `Keni · search`, `facetsOf`, `ALIAS`.

---

## 5. The place sheet

Opened by tapping a place. From top to bottom:

| Part | What it shows |
|---|---|
| Photo | The real cover photo, or generic art if there is none |
| Header | Kind and area, name, reviews, price range, open or closed |
| Address | With the distance from your area |
| Description | One or two lines about the place |
| **Vibe line** | The place's vibes. One you voted for shows "· 1 says so" |
| Still open? / How busy? | Quick reports from visitors (section 8) |
| Been here strip | Shows after you tap "Been here?", with the vibe check |
| Buttons | Save, Been here?, Send to a chat, Share |
| Tune your feed | More like this / Not for me |

Then five tabs:

- **Overview:** contact and hours, quick links (Call, Facebook, Instagram, Website, Look it up, Directions), Good to know, Why it matches you, and **Tagged by the community**.
- **Menu** (or **Prices** for non-food places): the real menu where one has been sent.
- **Reviews:** your own review. Real places start with none.
- **Photos:** the cover photo, extra photos the owner sent, and any you add (kept on your device).
- **Map:** the pin for that place.

Find it in the code: `detailHTML`, `overviewPaneHTML`, `vibeLineHTML`, `KENI_MORE`.

---

## 6. Vibes and tags

There is one vibe list, used everywhere: **Cozy, Barkada, Quiet, Aesthetic, Romantic, Retro, Hidden gem, Outdoorsy.**

- **Listed vibes:** each place has vibes chosen when it was added. They were picked by us from the photos, not by owners or visitors.
- **Vibe check:** after "Been here?", a box asks "Ano'ng vibe dito?". One tap saves your vibe for that place.
- **Tagged by the community:** starts with the 8 vibes, then 11 fact tags (Fast Wi-Fi, Plenty of outlets, Pet-friendly, Sulit, Nice and cold, Easy parking, Open late, Kid-friendly, Live music, Great views, Good for celebrations). You can also type your own tag.
- The vibe check and the vibe tags are **the same save**. A tap in one updates the other, the vibe line, and the map's vibe row.
- It is **one vibe per person per place.** Tapping another moves your vote.
- A place's listed vibes show at the top of its tags with no number. A number only appears from a real tap.
- **Demo.** Counts only include your own taps, so the most you will see is 1. Adding everyone's taps together needs a backend.

Find it in the code: `VIBES`, `vibesOf`, `S.vibeCheck`, `vibeAsk`, `TAGS`, `tagSection`.

---

## 7. Tropa mode (deciding as a group)

Opened from the people button in the top bar. Four steps:

1. **Crew:** who is going. You can keep several tropas and switch between them.
2. **Trip:** "Anong trip ngayon?" Each person's trip, budget and vibe (optional). Usual answers are pre-selected; the vibe comes from each person's profile.
3. **Where:** a meeting pin, and how far: Walking, Short ride or Anywhere.
4. **Pick:** Keni's best place for the group, with each person's match. You can lock it in, see another, or see other options.

How the pick works:

- **Hard no's:** a place someone will never do is taken out. Those places are listed under "Voted by someone".
- **Budget is personal.** A pricey place only counts against the person it is too pricey for.
- **Taking turns.** Whoever did not get their way is owed one. Next time, places that give them their trip rank first.
- **Tropa deals.** If the pick has a group deal, it shows under the pick, with "Show at the counter" once the group is big enough. It never changes which place is picked.
- **The group's vibe is a must** (added 2026-10-14, because interviewees said vibe matters a lot). The vibe most of the tropa picks becomes the group vibe, and the top pick has to be a place where that vibe is confirmed, either listed or tapped by visitors. If none fits in range, the card says so and shows the next best fit. Each person's own vibe also lifts places that match it for them.
- **Fair scoring.** Full listings and basic places are scored the same way, with no head start for having paid for set-up. A full listing wins only on what it can confirm: open now, budget and vibe. A half point breaks an exact tie.
- **What Keni can vouch for.** The pick card says "✅ Confirmed: hours, price, vibe" for a full listing, or "ℹ️ Basic info: vibe unknown, hours and price not listed. Check before you go" for a basic place, with a link to a sure alternative when there is one.
- **After the visit.** The locked ticket asks "Been there? What was the vibe?". One tap saves the vibe (the same save as the vibe check) and marks the place as visited, so the next tropa gets a confirmed answer.

Hidden for now (section 8): **Swipe to choose**, where the results become a deck to swipe, and the **Shared wheel**, where everyone adds spots and one spin gives the same winner on every phone.

**Demo.** You answer for your friends on one phone. Each friend answering on their own phone needs a backend. Friends in the demo are made up.

Known limits: someone blocked by another person's hard no can stay owed for a long time, and the top pick can be a closed place unless "Open now" is switched on.

Find it in the code: `BARKADA MODE`, `groupFor`, `vetoOf`, `Keni · swipe`, `Keni · swheel`, `Keni · tropa`.

---

## 8. Other features

| Feature | What it does | Status |
|---|---|---|
| **Pasabit** | A plan someone posts on the map that others can tag along on. Open ones have the host approve first ("Ask to tag along"); friends-only ones let you straight in ("Pasabit ako!") | Demo: sample Pasabits are generated each day |
| **Spin the wheel** | Put places on a wheel and let it choose. Use a ready list or pick your own spots | Works on the device |
| **Chats and friends** | Message friends, send them a place, run a poll. Tagging along on a Pasabit opens its group chat | Demo: replies are simulated |
| **Been here** | Mark places as visited. This opens the vibe check | Saved on the device |
| **Still open? / How busy?** | One-tap reports on a place. "Quiet now" in Filters uses them | Demo: only your own reports on real places |
| **Reviews and photos** | Rate a place and add your photos | Saved on the device only |
| **Saved** | The heart on any place | Saved on the device |
| **Share** | Share a place, or send your taste to a friend as a link | Works without a server |
| **Report a problem** | "⚑ Report a problem" at the bottom of every place: Wrong kind, Closed for good, Wrong location, Not a real place, Something else. On a **basic place** it applies straight away: a fixed kind is used everywhere, and closed or not-real places are hidden. On a **full listing** nothing changes by itself: the report shows in the owner's Studio ("Reports from visitors") and goes to the Keni team. Undo is always there | Demo: reports stay on the device (`S.reports`). With a backend they'd be shared, and a basic place would change for everyone once a few people agree |

### Hidden for now (2026-10-14)

To keep Keni to one main loop, these are switched off with one on/off list near the top of the data script. Search for `KENI_OFF`, and set one to `false` to bring it back. Nothing was deleted.

| Switch | What it hides |
|---|---|
| `sharedWheel` | The Shared wheel in Tropa mode |
| `swipe` | Swipe to choose in Tropa mode |
| `bookings` | "Reserve a table", My reservations, and the Studio's Bookings tab and "bookings waiting" tip |
| `scout` | Scout points and levels (Newbie, Explorer, Local scout, Trusted scout) |
| `mustGo` | Keni's must-go list. "Been here" stays |
| `imHere` | "I'm here" on the hold-the-map ring |

Spin the wheel, Pasabit and Chats were kept on purpose.

Also hidden, from before: **Plan my night**, the **craving search**, and the old Plan hub.

Switched off: the **Movies** kind and SM Clark Cinema. Search the code for `switched off` to bring them back.

---

## 9. The owner Studio

For a signed-in owner with a claimed place. Five tabs (Bookings is hidden for now):

| Tab | What it has |
|---|---|
| Overview | Profile views, Saves, Menu opens, Map taps; "Who'd love" the place; where people find it; a "Do next" list |
| Listing | Edit the details customers see, with a customer preview |
| Menu | The menu manager |
| Promos | Create and manage promos, and the slow-hour boost |
| Bookings | Today's and upcoming reservations |
| Reviews | Rating and an inbox to reply from |

- **Demo.** The numbers are generated, not counted. Edits are saved on the device and show on the customer side straight away.
- Owners can "Close for today" and "Preview as customer".

### Earning (demo, added 2026-10-14)

Students use Keni free. Owners pay, in three ways. Every price is an example to test with owners, and **no real payment happens anywhere**.

| Way | Where in the Studio | How it works | Demo price |
|---|---|---|---|
| **Listing set-up** | Overview → "Let Keni set it up". Also offered in Request a listing | A one-time fee for the Keni team to photograph the place and build the listing. Basic: photos and hours. Standard: adds the full menu. Full: adds a short video and a first Tropa deal | ₱300 / ₱600 / ₱1,000; menu refresh ₱150 |
| **Boosts** | Promos → Boosts | Switching on a slow-hour boost uses one boost. The first is free. A "Your last boost" card shows how many students saw it (sample numbers). Students see the deal with a "⚡ Boosted" label | ₱50 each, or 6 for ₱250 |
| **Tropa deals** | Promos → New promo → type "Tropa deal" | A perk for groups of a set size, such as "4 or more: free fries". It shows on the place and next to the pick in Tropa mode. The group taps "Show at the counter" | ₱99 to post |
| **Owner events** | Promos → Post an event | A pin on the map marked "posted by the owner". Students can tag along like any Pasabit | ₱99 to post |

**The Tropa deal code.** The counter screen shows today's code, such as KN-6550, and a live ticking clock, so a screenshot won't pass. The owner's Studio shows the same code. Both are worked out from the place and the date, so they match on any phone without a server. The owner taps "＋ Group used it" to count redemptions. The code is easy to work out for anyone who reads the app's code, so a real launch should make it server-checked.

**Rules:** paid things are always labelled. A deal sits beside the Tropa pick but never changes which place wins.

Not built: the monthly plan, which was dropped because Google gives owners listing control and numbers for free, and payments inside the app, which students are unlikely to use.

Find it in the code: `Business Studio`, `STUDIO VIEW`, `earning (demo)`, `walletHTML`, `dealCode`, `openDeal`, `postOwner`, `setupHTML`.

---

## 10. Profile and settings

- **Profile:** photo, name, About me, My taste, Listing requests, My Pasabits, My tropas, Sign out. (Scout level, Been there and My reservations are hidden for now.)
- **Edit profile**, **Settings** and **Privacy** are buttons at the top of the profile.
- **Settings:** Larger text, Reduce motion, what the map shows when it opens, the "Anong trip mo?" row on or off, Replay the tutorial, Redo my taste, Clear everything on this device.
- **Privacy:** who sees your profile and photos, your location, and what Keni learns.

---

## 11. The places

18 places are listed. All are real, with pins, hours and contacts taken from their Google Maps listings.

| Place | Kind | Area |
|---|---|---|
| Rio St. Coffee | Café | Angeles City |
| Camp Luna | Café | Angeles City |
| the usual. | Café | Angeles City |
| Hyphy Bodega | Café, Inuman | Friendship Hwy |
| Coffeebay | Café | Friendship Hwy |
| Cafe Retro 252 | Café | Friendship Hwy |
| Cafeinn | Café | Friendship Hwy |
| Poca Cafe | Café | Angeles City |
| Chicken Joo | Foodtrip | Angeles City |
| 24 Chicken | Foodtrip | Angeles City |
| Chicken Avenue | Foodtrip | Angeles City |
| Boom Chicken | Foodtrip | Friendship Hwy |
| RICH Taste | Foodtrip | Angeles City |
| Pool HUB | Sports | Angeles City |
| Pickle Place | Sports | Pulung Maragul |
| AQUA KTV | KTV | Balibago |
| Saturday Night at CGC | Tambayan | Clark Freeport |
| Clark Parade Grounds | Outdoors | Clark Freeport |

- **Real menus or prices:** Rio St. Coffee, RICH Taste, Poca Cafe, Pickle Place.
- **Every place has a cover photo.** RICH Taste, Poca Cafe and Pickle Place also have extra photos in their Photos tab.
- **Kinds of place (9):** Café, Foodtrip, Sweets and drinks, Inuman, KTV, Sports, Outdoors, Gala, Tambayan.
- **Areas (7):** Balibago, Angeles City, Clark Freeport, Pulung Maragul, Friendship Hwy, Pampang, Dau.

### Basic places (added 2026-10-14)

Besides the 18 full listings, Keni has 1,441 **basic places** from OpenStreetMap: 888 restaurants, 295 cafés, 191 sports places, 66 parks and 1 KTV. Each has only a real name, a pin and a kind.

**Bars are left out for now** (2026-10-14): many bars in the list, around Fields Avenue in Balibago, are adult clubs. Drinking spots only come from full listings that have been checked. To bring bars back, add `'Bar': 'inuman'` to `KIND` in "Keni · basic places".

- **Their page** says "Basic info only", shows "Price not listed" and "Hours not listed", and has Directions, Look it up and an "I own this place" button that opens the owner sign-in.
- **They work with** Save, Been here, the vibe check, tags and Tropa mode.
- **In Tropa mode** they're scored the same way as full listings (section 7). They can't confirm hours, price or vibe until visitors add a vibe, so with "Open now" on, or a group vibe chosen, they can't be the top pick. An unknown price counts as neither good nor bad for a budget.
- **In Explore** they're listed after the full listings as "More places nearby", nearest first, 30 at a time.
- **In search**, a matching spot says "basic info on Keni" and opens its page.
- **Upgrading:** when a full listing is added with the same name within about 250 m, its basic place disappears by itself, so a place never shows twice.

Find it in the code: `Keni · basic places`, `KENI_SPOTS`, `v.basic`, `passes`, `allPlaces`, `#basic-more`.

**The rule for real places:** nothing invented is shown. No made-up photo, rating, review, menu, contact or tag count. Unknown hours say "Hours not listed".

**How a place is added:** the original photos go in `photos/<place>/`. The place is written as an `R(...)` entry above the line "new places go above this line". Its cover photo is saved as a file in `images/real/`, extra photos in `images/more/`, and both are listed in `KENI_IMG` / `KENI_MORE`. Its menu goes in the menus list.

---

## 12. First-run tutorial and motion

- The tutorial runs once after sign-up. Each step lights up one real control and waits until you use it. Every step can be skipped. Replay it from Settings.
- Animations are short and play once: the fly-in when the map opens, pins dropping in, chips sliding in, a small burst on taps.
- "Reduce motion" in Settings turns them off.

---

## 13. Where things are saved

Everything is in the browser's local storage on that device.

| Key | What it holds |
|---|---|
| `keni.v1` | Almost everything: sign-in, saved places, tropas, trips, vibe checks, tags, reports, requests, settings |
| `keni.photos.v1` | Photos you add to places |

Clearing the browser data, or "Clear everything on this device" in Settings, erases it. Nothing is shared between devices.

---

## 14. What needs a backend before a real launch

- Real sign-in and real accounts.
- Friends answering Tropa mode on their own phones.
- Counting everyone's vibe checks, tags, reports and reviews together.
- Chats, Pasabits and reservations between real people.
- Listing requests reaching the Keni team, and checking ownership.
- Real numbers in the Studio.
- Payments, if owners are charged.
- "Ask Keni" AI. An AI key must never sit in the app file.

Security notes: the Mapbox token in the app is a public one (it starts with `pk.`) and is not yet locked to the Keni URL. Never put a token that starts with `sk.` in the app.

---

## 15. How the file is built

- `keni.html` is one file of about 1.2 MB, with plain JavaScript and no build step. Since 2026-10-14 the photos are separate files in the `images/` folder, and each one only downloads when someone looks at it. (Before, they were inside the file, which made it about 10 MB.)
- It is not in git. A copy is saved in `backups/` before each feature.
- The core exposes `window.KeniCore`. Each feature is its own `<style>` and `<script>` block further down the file.

The script blocks, in order:

| Block | Search for |
|---|---|
| Photos of the real places | `real photos of the listed places` |
| Places, kinds, vibes, areas | `sample data for Angeles City` |
| Menus | `Keni · sample menus` |
| Core: state, matching, onboarding, map, place sheet | `Keni — app logic` |
| Tropa mode (and the hidden Plan my night and craving search) | `Keni · Plan hub` |
| Owner Studio and claiming | `Keni · Business Studio` |
| Profile and sign-in | `Keni · Profile` |
| Tags | `Keni · community` |
| Still open?, scout levels, slow-hour nudges | `Keni · live` |
| Several tropas | `Keni · tropa` |
| Spin the wheel | `Keni · wheel` |
| Shared wheel | `Keni · swheel` |
| Swipe to choose | `Keni · swipe` |
| Chats and friends | `Keni · friends + messages` |
| Reservations | `Keni · reservations` |
| Reviews and photos | `Keni · reviews + photos` |
| Been there and the vibe check | `Keni · been there` |
| Pasabit | `Keni · Pasabit` |
| Tropa screen | `Keni · tropa screen` |
| Edit profile and settings | `Keni · edit profile` |
| Tutorial | `Keni · tutorial` |
| Hold the map | `Keni · hold the map` |
| Map look | `Keni · map look` |
| OpenStreetMap landmarks | `Keni · map spots` |
| Search | `Keni · search` |
| Map motion | `Keni · map motion` |

To run it locally, use the `keni` preview server in `.claude/launch.json`. It serves `keni.html` and the `images/` folder. To deploy, copy `keni.html` to an empty folder as `index.html`, **copy the `images/` folder next to it**, and run `npx --yes vercel@latest deploy --prod --yes --scope keni4` from there, linked to the `keni-update` project.

---

## 16. Keeping this file true

Update this file in the same sitting as any feature change: add the feature to its section, and change the date at the top. If something is removed, remove it here too, or move it to "hidden" or "switched off" in section 8.

---

## 17. The real version (`keni-real/`, started 2026-10-14)

Sections 1–16 describe the demo, `keni.html`, which stays frozen for the pitch. The real, launchable Keni is a separate copy: `keni-real/index.html` plus its own `keni-real/images/`. Run it with the `keni-real` preview server (port 5176). It is live at https://keni-real.vercel.app (Vercel project `keni-real`; deploy from inside `keni-real/`). `keni-real/` is its own git repo, on GitHub at https://github.com/muss-s/keni-real (private).

**Deleted from the real version (not hidden):**
- The demo tropa (Mika, Jun, Bea, Carlo), "Load demo tropa", and the "friend tagged this place" lines.
- Plan my night, What are you craving?, and the old Plan hub. Tropa mode is the only thing on the `plan` view.
- Fake social sign-in (Google / Facebook / Instagram / TikTok and the "Juan Dela Cruz" profile). Signing in is now **your name only**, on the welcome page, in step 4, and in the sign-in sheet. Real accounts come with the backend.
- The stock profile photo for signed-in people.
- The whole old Studio: made-up stats, audiences, tips, sample reviews, demo bookings, the boosts wallet, fees, set-up packages, demo owner logins, the 4-digit "any code works" check, and the earning CSS.
- Reservations (the Reserve button). Nothing was ever sent to a venue.
- The sample slow-hour deals, the old fictional place lists (`SAMPLE_VENUES`, `WELL_KNOWN`), and every made-up menu. Only Rio St. Coffee's menu is left, copied from its menu photos.
- Inside Chats: the fake people (Andrea, Paolo and others), fake friend requests, simulated replies and simulated poll votes.
- Inside Pasabit: the daily sample Pasabits, simulated "tag along" answers, and the simulated host messages.

**Switched off until the backend (code kept):** Chats (`KENI_OFF.chats`, and the dock button is hidden) and Pasabit, which only runs when Chats run. Nobody else can be in a chat or a Pasabit without a server. The plan: step 2 is the backend with accounts (Supabase Auth), tropas by link, shared vibe taps and shared reports. Step 3 is Pasabit, with reporting, blocking and approving who joins.

**The new Studio** (`Keni · Studio`): "I own a place" asks for your name, then lets you either claim a place that is already on the map (full or basic listing) or request a new listing. Both need a page or a number to check. Requests show in the Studio as "⏳ Waiting for a check" and can be cancelled. The owner tools (listing, menu, promos, reports) are listed as coming once the place is checked. For now requests stay on the phone (`S.biz.claims`, `S.biz.requests`). Until the backend, you are the admin: you add places by sending them to Claude, and later through the Supabase dashboard.

**Fixed in the real version only:**
- The map stayed blank when location was off at first load, because the location prompt was added to the empty map area first.
- The place count on the map could show an old number after the places changed, because the small-places code wrote back a saved copy of the count when the map moved.

Both bugs are still in the demo.

### Places live in the database (added 2026-10-14)

Supabase project **keni** (Singapore, free plan), table `public.places`. It holds every place: the 18 big listings (`level = full`) and the 1,441 small pins (`level = basic`). Everyone can read places that aren't hidden. Only the Keni team can change them, from the Supabase dashboard.

How the app gets them (`Keni · places from the database`):
- On open, the copy saved on the phone (`keni.places` in the browser) is used straight away, so there's no waiting.
- Then a tiny check asks how many places there are and when the last one changed. Only if that's different is the full list (about 400 KB) downloaded, swapped in, and saved for next time.
- The place lists inside the file are only a fallback for the very first open while offline. The database wins.

**Adding a big place** (Supabase dashboard → Table Editor → `places` → Insert row):
- `id`: short and unique, e.g. `kape-ni-juan`.
- `name`, `lat`, `lng`: the pin. Copy the coordinates from Google Maps.
- `kinds`: main kind first, e.g. `{cafe}`. The column notes list the options.
- `area`, `price`, `blurb`, `vibes`, `hours` (e.g. `[9, 22]`, empty = "Hours not listed"), `contacts`.
- `photo`: upload the picture to Storage → `place-photos`, copy its public URL, and paste it here.

It shows on everyone's map the next time they open Keni.

**Promoting a small pin:** open its row (ids start with `b-`), fill in the details, and set `level` to `full`. **Taking a place off the map:** set `hidden` to true. That's better than deleting, because people's saves and vibes keep pointing at the same id.

### Accounts (added 2026-10-14)

Accounts are **email + password** (Supabase Auth, `Keni · accounts`). The same step-by-step form is used on the welcome page, in step 4, and in the sign-in sheet:
- **Start:** two buttons, Make an account and Sign in, plus I own a place and Skip.
- **Make an account (email checked first, since 2026-10-15):** step 1 name → step 2 email (Keni emails a 6-digit code; Email OTP Length is set to 6 in Supabase) → step 3 enter the code (Resend code / Change email) → step 4 password + confirm password (at least 8 characters). No usable account exists until the code is right. If the email already had an account, the code just signs them in. The Supabase email templates **Confirm signup** and **Magic link** must contain `{{ .Token }}` so the code is in the email.
- **Sign in:** email + password, with Forgot password? (emails a reset link; opening it asks for the new password twice).
- **Profile:** shows "Signed in as … · Change password", or Make an account · Sign in.
- **Owners:** "I own a place" asks them to sign in first, then claim their place.
- Guests can skip and use Keni on the phone only.

**What the account holds:** `public.profiles` (name, photo, bio), made automatically at sign-up. Signed-in people can see names and photos; only you can change yours. Editing your profile updates it. Sign out and Reset Keni also sign out of the account. Taste, saves and tropas still stay on the phone.

**Limits for now:**
- By default Supabase asks new accounts to confirm their email. That uses its built-in email sender, which only sends a few emails an hour. To switch it off: Supabase → Authentication → Sign In / Providers → Email → Confirm email.
- Before launch, connect your own email sender (Authentication → Emails → SMTP).

### Tropas by link (added 2026-10-14)

Supabase tables `public.tropas` and `public.tropa_members`, reached only through the `tropa_*` functions (`Keni · tropa sync`):
- **Invite:** shows one link (…/#t=CODE) with Share or Copy. The tropa becomes shared the first time someone makes the link, and the friends already added by hand come along.
- **Opening a link:** shows "You're invited · Join …" with the people already in. Type your name and you're in. No app install or account needed.
- **Syncing:** while Tropa mode is open, every phone sends what changed and pulls the rest every 4 seconds: who's in, taste and hard no's, tonight's answers, who's out, where you're meeting, and the locked pick. When someone locks a pick, every phone jumps to "Locked in".
- **Who can do what:** knowing the code lets you see the tropa. Being a member (your account, or the secret your phone got when you joined) lets you change it. Inside a tropa anyone can change anyone's answers.
- **Signed in:** you join as your account. Your shared tropas come back on any phone you sign in on. Add friend shows "Your friends on Keni" (people you already share a tropa with); tapping one adds them, and it shows up in their app.

Limits: polling, not live push; up to 30 people per tropa and 6 tropas per phone.

- **My tropas (added 2026-10-15):** a **Tropa** button in the dock, left of Explore (where Chats sits when chats are on); it opens My tropas, and the same screen opens from the profile. It shows your tropas to switch between, New tropa, rename and emoji, the people in the tropa (On Keni / Joined with the link / Added by you) with Remove, the invite link and code (Share invite / Make invite link), Add friend, Join with a code, people from your other tropas, Leave or Delete, and Plan with this tropa. The UI says "tropa", never "crew": the first step is labelled Tropa, and the fold is "People in this tropa".
- **Tropa info (real app, added 2026-10-23):** tapping the photo or name at the top of a tropa chat opens a tropa info screen: the big tropa photo (tap to change), the name, people count and code, Add people, the people in it, and Leave tropa (tap twice). It has no tropa switcher; switching and renaming stay in Manage.
- **Tropa nicknames (real app, added 2026-10-25):** in tropa info, tap the pencil next to anyone (yourself too) to set a nickname of up to 20 letters, or Clear it. Anyone in the tropa can do it. The nickname shows in that tropa only: its chat, Chats list, pushes and people list (with the real name underneath). The chat shows "Aimiel set Ganda’s nickname to Gandara".
- **Replies (real app, added 2026-10-26):** in any chat (tropa, friend, Pasabit), swipe a message (someone else’s to the right, yours to the left) or long-press it and tap the reply arrow. A bar above the box shows what you’re replying to (X cancels). The sent message shows a short quote on top; tap it to jump to the original. If the original was deleted it says "Message removed".
- **Menu photos (real app, added 2026-10-26):** on any real place, the Menu tab has a Menu photos box. Signed-in people tap Add menu photo (up to 5 at once; Keni shrinks them). Photos wait for an admin (admin page → To do → Menu photos waiting → Approve or Reject, with undo); the person gets a notification either way. Approved photos show as a swipe strip with "Added by Name · month"; tap one for a full-screen view (swipe between photos, pinch or double-tap to zoom). Your own waiting photos show to you as "Waiting for review". Max 10 waiting per person.
- **Place photos (real app, added 2026-10-27):** the Photos tab on any real place has From people: signed-in people tap Add photos (up to 5 at once). They go to the same admin review as menu photos (To do → Photos waiting, labelled Place photo or Menu photo), with a notification either way; the 10-waiting limit covers both kinds. The newest 4 approved photos also show as a row on the overview (tap for the full-screen viewer, or All photos / +N more). Photos saved on your phone earlier still show to you, with a Share it with everyone button that sends them for review. If the place has no cover photo, the first approved place photo becomes its cover (Undo in admin removes it again).
- **Owner claims and Studio (real app, added 2026-10-27):** an owner opens Studio (or "I own a place"), searches for their place and claims it: they say if they are the owner, manager or staff, give a number or page the Keni team can check, can add a photo of their business permit or sign (only the Keni team sees it), and a note. The claim waits in the admin To do ("Owner claims"), where the team checks the contact and approves or rejects it with a reason (with undo). The person gets a notification and a push. Once approved, Studio lists "Places you manage": Edit listing (cover photo, about, hours for each day, price, contacts, good to know) goes live right away, Reports shows what people reported about the place (not who), and View opens the place. Name and pin changes still go through the Keni team. Every edit is saved with its old values so a bad one can be undone. A small pin that gets claimed becomes a full listing. Weekly numbers are shown as coming soon.
- **Promos and events (real app, added 2026-10-28):** in Studio, each place you manage has "Promos & events". An owner posts a promo (the deal, details, start and last day, which days, price, optional photo) or an event (name, details, date, start time, entrance, optional photo). A place can have 3 live at a time; each one comes down by itself after its last day, and the owner can edit it, end it early or post an old one again. People see them as a banner at the top of the place page, a small pink badge on the pin, the deal on the place card, a "Deals & events" row first in Explore (today's deals plus events in the next week) and a "Deal today" / "Event tonight" tag in a tropa vote. Anyone can report one as fake (once per phone). In admin, the Promos tab lists every live one and those taken down this week; reported ones also show in To do. The team can take one down with a reason (the owner gets a notification and a push) and put it back. Saved places are only on each phone, so there is no push to people who saved the place yet.
- **Your plan card (real app, added 2026-10-28, display only):** in Studio, under Places you manage, a "Your plan" card shows the free trial (30 days from the day the claim was approved) and three swipeable plans: Basic ₱500/month (edit listing, cover and blurb, reports), Premium ₱1,299/month (adds promos and events, pin badge, Explore row, vote tag) and Sponsored (custom). Nothing is locked or paid; the Choose buttons only explain that every tool is free during the trial. Also: "I own this place" on a small-pin page now opens the claim for that place directly.
- **Your numbers (real app, added 2026-10-28):** in Studio, a "Your numbers" card per managed place shows how many people viewed and saved it in the last 7 days, the change vs. the 7 days before, and a bar per day (today highlighted), with a Refresh button. Each phone counts once a day per place; the place's own managers are not counted. Data: table `place_hits`, functions `place_hit` (called when a place page opens or a place is saved) and `owner_stats`. Replaces the old "Coming soon" card.
- **Leave tropa (added 2026-10-15):** for a shared tropa, the tropa bar shows **Leave tropa** (tap twice) instead of Delete. It removes your place on the server (`tropa_leave`), then this phone's copy. Friends see you go within seconds. When the last person leaves, the tropa is deleted. Leaving your only tropa gives you a fresh empty one. Tropas that only exist on the phone still use Delete.
- **Join with a code (added 2026-10-15):** Tropa mode → Manage crew → **Join with a code**. Type the tropa code (or paste the whole link) and you get the same join screen as the link. The invite sheet also says "Or tell them the code …". Each tropa has one code, and there is no way to change it yet.
- **Fixed 2026-10-15:** people are removed from a tropa only when someone taps Remove or Remove all, never because a phone's list is missing them. That had removed the owner of a tropa after they opened their own invite link. Each copy of a tropa keeps its own sync record, duplicate copies on one phone are merged on start, and a phone no longer re-sends the same change every few seconds.

### Place page: Contact & hours

The quick buttons and rows use line icons instead of emoji: call, Facebook, Instagram, website, look it up, directions, clock, pin. Facebook and Instagram show the page name only. The styles for this box had been deleted along with the reservation styles and were put back on 2026-10-14. The made-up contact details for sample places were removed.

### Reports and the admin dashboard (added 2026-10-14)

- **Reports:** "Report a problem" sends every report to `public.reports`, one per place per phone; sending again replaces it, and taking it back deletes it. Anyone can send. Only admins can read them.
- **Admins:** listed in `public.admins`. The first one is the owner's account (aimielmarasigan@gmail.com). To add someone, add their user id to that table in the Supabase dashboard.
- **Dashboard:** `keni-real.vercel.app/admin` (`keni-real/admin.html`, not linked from the sign-in page). Sign in with a Keni account. Non-admins see "Not allowed", and the database refuses them anyway.
  - Tabs: New / Fixed / Dismissed / All, with a count of new reports.
  - Reports are grouped by place, showing reason, note, time, and whether it came from an account or a guest.
  - Buttons: Mark fixed, Dismiss, Reopen, Look it up.
  - **Fix the place:** edit name, main kind, hours, pin, or hide it from the map. The change shows on everyone's map the next time they open Keni.
  - Refreshes every 30 seconds.
- **Admin button:** a signed-in admin sees "Admin" next to "Signed in as …" in their profile.
- **PC layout (2026-10-29):** the admin page is built for a computer. A sidebar lists Overview, To do, Places, Owners, People, Place reports, Promos and Tags with counts. Under 900px wide the sidebar becomes tabs on top and To do goes back to stacked cards.
  - **Overview:** people (new this week, active), tropas and messages, places with hours and photos, owners, claims waiting, promos live, place views and saves, phones with notifications, plus 14-day charts of sign-ups and place views (`admin_overview`).
  - **To do:** a queue on the left (reported promos, owner claims, photos, new places, place reports, reported people, reported Pasabits) and the selected item on the right. Keys: J/K or arrows move, A approves (or marks handled), R rejects (or takes down / cancels).
  - **Owners:** every claim in a table with filters (Owners, Waiting, Not approved, All) and search. Remove (tap twice) stops someone managing a place, turns a small pin back, and ends their live promos; Undo or Put back restores them (`owners_admin`, `owner_remove`, `owner_restore`).
  - **People:** search by name, @username or email; joined, last sign-in, tropas, friends, places managed, open reports. Click a row to see reports about them (`people_admin`).
  - **Reported people and Pasabits:** shown in To do with Handled / Reopen; a Pasabit can be cancelled or brought back (`people_reports_admin`, `report_handle`, `pasabit_admin_cancel`). Keni can't ban accounts yet.
  - **Places:** a table (kind, area, pin, hours, added by); click a row to edit it.
- **Map bar (real version):** the place counter ("18 places") and "Show all" were removed; only "Near me" stays on the map.
- **Folding question rows (real version):** on the map, tap **Plans** or **Vibes** (renamed from "Anong trip mo?" and "Anong vibe?") to open or fold its row (chevron turns). Both start folded; a picked chip stays visible when its row is folded, so you can always see and clear what is filtering. The choice is remembered on the phone (localStorage `keni.fold`). The first-run tour opens the trip row by itself on its step.
- **Filters in the search bar (real version):** the Filters chip moved into the search bar as a sliders icon on the right; a pink number shows how many filters are on. It opens the same Filters panel.
- **Round Tropa button removed (real version):** the round people button on the map (and the Tropa mode button in the top bar) is gone; the dock Tropa button does the same job. The first-run tour points at the dock button instead.
- **Cravings (added 2026-10-15, real version):** a food you want right now: Chicken, Sushi, Tusok-tusok, Ramen, Samgyup, Burger, Pizza, Pares & lomi, Sisig, Milk tea, Sweets. A chip only shows when some place has it.
  - **On the map:** a third foldable row, **Cravings**, under Plans and Vibes (starts folded). Tapping one shows only the places that have it, picks its plan (Foodtrip, or Kape for Milk tea and Sweets), and zooms the map to them; basic places show at any zoom while a craving is on. Tap it again to clear; tapping a different plan clears it too.
  - **In Tropa mode:** "Tell me what you’re craving?" (optional, pick any) in the Trip question for each person. A place with one of their cravings scores higher for them, one without scores a bit lower. The summary line says what the tropa is craving, and the pick card shows which cravings the place covers. Friends with the link answer on their own phone (synced with the other answers).
  - **Which places have what:** the `cravings` column on `public.places` (ids above, e.g. `{ramen,chicken}`). Empty = Keni guesses from the name, kinds and menu (e.g. "Ramen" in the name). Tell Claude, or edit the column in Supabase. Tusok-tusok and Sisig have very few places so far, so they need tagging.
  - **Silog (added 2026-10-16):** 🍳 Silog, a Foodtrip craving. Keni guesses it from "silog", "tapsihan", "tapa", "longganisa" or "tocino" in the name (8 places at launch, e.g. tapsilogans). Sisig's emoji changed to 🥘 so the two don't share 🍳. Adding a new craving id means updating three places: `CRAVES` in `index.html`, `CRAVES` in `admin.html`, and the DB allow-list `public.craving_ok()`.
- **Plan label:** the food plan is called **Foodtrip** (not "Gutom") in the real version.
- **Matching screen (real version):** the radar, counters and "Matching your tropa" panel were replaced by a short Keni logo animation (the pin hops, two rings pulse, "Finding your spot..."). It lasts about 1.4 s, then shows the pick.
- **Plans, Cravings and Vibes work together (real version):** tapping a plan or craving no longer clears a vibe you already picked (it used to when no place matched both). If nothing matches the mix the map says "No places match"; tap a chip again to clear it. A craving still sets its own plan (Foodtrip or Kape).
- **Cravings now work with Plans (real version):** a craving no longer picks or replaces the plan. Plan + craving + vibe all apply together, so "ramen at an inuman" and "ramen at a cafe" are different searches. In Tropa mode a craving no longer fills in the Trip answer either. A place only appears for a mix if it has both the plan kind and the food (tag a cafe that sells ramen with both its kinds and the `cravings` column).
- **Community tagging of cravings (real version, deployed 2026-10-15):** on a place page, a "Serves" line shows its foods with "N say so" counts and a **Tag what they serve** button. Only signed-in people can tag (guests get the sign-in screen). One vote per person per place and food; tap again to take yours back. A food shows on the map once **2 different people** agree (`COMMUNITY_MIN`); Keni's own tags always count. Stored in `public.craving_votes`, used only through `craving_tags` / `craving_vote`. The admin page has a "Cravings tags from people" list with a **Remove** button (`craving_clear`).
- **Add a place with a backend (real version, deployed 2026-10-15):** only signed-in people can add (guests get the sign-in screen). Open it from the hold-the-map ring ("Add a place here") or the Added strip. First question: **Who can see it?**
  - **Gatekeep?**: only the adder's tropa sees it. Just a name, a symbol (16 to pick from; it is the pin) and the pin location. It shows on the map with that symbol and a small 🔒; the place page says "Gatekeep · only your tropa sees this" and has **Make public (needs approval)** and Edit. Tropa mates must be signed in to see it.
  - **Everyone**: needs admin approval first (the screen says so). Questions: name, kind + what they serve (optional), where, vibes, hours + price, photo + one-line description (optional), review. Until approved only the adder sees it ("Waiting for approval"). Limit: 5 waiting places per person.
  - Stored in `public.places` (`added_by`, `visibility`, `status`, `symbol`), written only through `place_add` / `place_update_mine` / `place_remove_mine` / `place_publish`; row security decides who gets which rows. The app loads them in the "Keni · my places" module (never into the shared places cache).
  - **Admin page:** "Places waiting for approval" list with **Approve** / **Reject**.
  - Old places saved on a phone before accounts keep working (local copy).
- **Headings font (real version, deployed 2026-10-15):** headings, place names and big numbers use **Bricolage Grotesque** (weight 800, upright) instead of Instrument Serif (`--display`). The highlighted words keep the lavender → pink → gold gradient.
- **Sign-in sheet (real version, deployed 2026-10-15):** no "Your account" label, no explainer line, no "Continue as guest" (close with ✕). Sign in and Make an account both have a Back button. When something needs an account (like Add a place), a highlighted line says why.
- **Gatekeep = spots (real version, deployed 2026-10-15):** a "Gatekeep?" place is a **spot** (like "my crib"), not a listing. It is only a pin on the big map (its symbol + 🔒), never in Explore, search, ratings or tropa picks. Tapping it opens a small card: symbol, name, area and distance, 🔒 line, **Directions**, **Tropa meet here**, and for the adder Edit / Make it public (needs approval) / Remove (tap twice). Code: `K.mySpots`, `K.openSpot` in "Keni · my places".
- **No zoom on iPhone (real version, deployed 2026-10-15):** text boxes are 16px on iPhone, so tapping the search (or any box) no longer zooms the page.
- **Map filters in one row (real version, deployed 2026-10-15):** on the map, Plans, Vibes and Cravings are 3 pills in one row under the search button. Tap one and its choices slide out in a row under it (one open at a time); picking one closes the row and shows the pick on the pill (e.g. "🍗 Chicken"). Tap the pill again and tap the picked choice (✕) to clear it. **Near me** is now a round button at the bottom right, above the dock. Code: `ui.mfOpen`, `mapBar()` in `renderFilters`.
- **Map pills on the search row (real version, deployed 2026-10-15):** Plans / Vibes / Cravings sit on the same row as the round search button (between it and the map tools); the row scrolls sideways if it doesn't fit, and hides while search is open.
- **Admin panel remade (real version, deployed 2026-10-15):** `keni-real/admin.html` now has 4 tabs with count badges: **To do** (places waiting for approval as cards with photo, tags, a small map and big Approve / Reject, then new reports; "All clear 🎉" when empty), **Places** (search every place by name, filters All / Added by people / Hidden / Small pins, tap a row to edit name, kind, hours, pin or hide it), **Reports** (New / Fixed / Dismissed / All), **Cravings** (tags with Remove). Approve, Reject, Mark fixed and Dismiss show a toast with **Undo** for 5 seconds. Same look as the app (dark purple, Bricolage headings). Spots (Gatekeep?) are never listed.
- **Keni's own area labels removed from the big map (real version, deployed 2026-10-15):** the map's own town names are enough; they used to double up.
- **Explore sections (real version, deployed 2026-10-15):** with no filter or search on, Explore starts with sideways rows: **Open now near you** (closest open places), **Picked for you** (best matches; shows "✨ N% your vibe" only at 60% or more), **New on Keni** (places people added in the last 60 days; hidden until there are 3), **Craving something?** (food tiles; a tap opens the map with that craving on), then **Everything** (the full grid). A row needs at least 3 places to show. Code: "Keni · explore sections", `#xsec`.
- **Reports no longer change your own map (real version, deployed 2026-10-15):** a report only goes to the Keni team; the place stays as the database has it. Places an older version hid after a report come back.
- **Big or small pin on approval (admin, deployed 2026-10-15):** each place waiting for approval has "Show it as: Big pin (full listing) / Small pin (just a dot)"; Approve saves that as `level` (`full` / `basic`).
- **Full place editor (admin, 2026-10-30):** tapping any place in Places, "Edit everything" on a new place, or "Fix the place" on a report opens a side panel with every field: big or small pin, approved / waiting / rejected, hidden, name, every kind (the first is the main one), map symbol, area, address, the pin (drag it or tap the map), price, hours for each day (or closed, or not known; "Copy Monday to every open day"), hours note, description, vibes, good-to-know, cravings, phone, Facebook, Instagram, website, TikTok, and photos (add, make cover, reorder, remove). Saving updates the place right away, with Undo. The Places tab lists every place (with a count) and has a Full listings filter.
- **You on the map (real version, deployed 2026-10-15):** your spot on the big map is your profile picture (or your initial) in a small round bubble with a white ring and a point under it, like Life360 (34px). Guests get a 🙂 bubble. It redraws when your name or photo changes. Code: `homeIcon()`, `K.meAv`.
- **Tropa step icons (real version, deployed 2026-10-15):** the Tropa / Trip / Where / Pick steps use simple line icons (people, sparkle, pin, trophy) instead of the 3D pictures. Explore rows now animate without ever being hidden, so a phone that skips animations still shows them.
- **Admin Tags tab:** the Cravings tab is now **Tags** with Cravings · Vibes · Kinds and a Big pins / All places switch.
  - **Overview:** one row per tag with how many places have it and where it comes from (by Keni = saved on the place, by people = 2+ votes, guessed = from the name). Under 3 places shows "⚠ Needs tagging". Tap a row to see its places (✕ removes the tag from one) and to search and add a place.
  - **Needs tagging:** places with no craving (food and drink places) or no vibe, each with one-tap chips that save straight to `places.cravings` / `places.vibes` (Undo for 5 seconds). Adding a craving to a place that only had guesses saves the guesses too, so nothing disappears from the map.
  - **From people:** 1-vote tags get **Approve** (adds it to the place now) or Remove; 2+ vote tags get Remove.
  - **Kinds:** count per main kind; tap one to change any place's main kind from a dropdown. Wrong-kind reports link to Reports.
- **Admin animations** only slide in now (never start hidden), so rows can't get stuck invisible.
- **@usernames (real version):** sign-up is now 5 steps: name → **username** → email → code → password. The username box starts empty (not made up from the name) and checks as you type ("✓ @mia.cruz is available" / "✗ taken"). Rules: 3–20 of a-z 0-9 . _ (not starting or ending with . or _, no ".."), lowercase, a few reserved (admin, keni, support…).
  - **Unique in the database:** `profiles.username` with a unique index on `lower(username)` and a format check; `username_free(p)` answers "is it free?" (anon too, for sign-up).
  - Accounts made before usernames get a one-time **Pick your username** sheet after signing in (with Later).
  - **Edit profile → Username** checks as you type and saves to the database; a taken one shows an error and nothing is saved.
- **Admin sees who reported:** each report shows "from @username (Name)", "from Name · no username yet" or "from a guest". Places waiting for approval show who added them the same way. Names come from `public.profiles` (`reports.reporter`, `places.added_by`).
- **Usernames in admin Tags:** "From people" rows say who tagged it ("by @mia.cruz, @jo and 2 more"; a name if they have no username yet), and a place chip that's on the map because of people shows who agreed. `craving_recent()` now also returns `voters` (admins only).
- **Approving a people's tag (admin):** an approved tag leaves "From people · waiting" and moves to "On the map from people" with a ✓ approved tag. Remove on an approved one also takes it off the place.
- **Place links + Open in Keni:** `keni-real.vercel.app/#place=<id>` opens that place on the map with its page open (waits for places to load; says so if the place is gone). Each report group in admin has **📍 Open in Keni**, which opens the reported place in a new tab.
- Map filter pills (Plans, Vibes, Cravings) no longer show a dropdown arrow. They're tighter now.
- Profile: **Reset Keni** removed. **Sign out** (profile and settings) now goes back to the welcome page (Make an account / Sign in).
- **Cheaper map:** the main map is now a Mapbox vector map (Mapbox GL JS, drawn inside Leaflet by mapbox-gl-leaflet 0.0.16, mapbox-gl 3.15.0, loaded only when the map first opens). Mapbox counts it once per opening (50,000 free a month) instead of per picture tile (about 10–20 per pan or zoom). Keni Night / Light / Satellite still switch. The small maps (a place's Map tab, add-a-place, area and tropa maps) use OpenStreetMap's free tiles, made dark in CSS, and never touch Mapbox. If Mapbox refuses (limit or token), the main map falls back to OpenStreetMap; a phone without WebGL gets the old picture tiles.
- **Tropa mode top bar:** just the Keni logo. No search, area button or profile there.
- **iPhone scroll fix:** sheets (place page, profile, every other sheet) and other panels that scroll on their own could get stuck after scrolling to the very bottom or top on iPhone. Now, when a finger lands on one, it's nudged 1px off the edge first, so Safari keeps the swipe in the sheet.
- **Pending places stay private:** the app's map only shows approved public places, your own places (any state; an unapproved one says ⏳ Waiting for approval and stays out of New on Keni) and tropa gatekeep spots. Admins still see pending places, but only in the admin page. The database rule now only lets tropa mates see each other's gatekeep spots, never pending public places.
- **Planning redo (Tropa mode):** the dock's Tropa button opens planning straight away. The tropa chip at the top (🔥 Squad · 1 going) opens Your tropas (switch, rename, people, invite). Just you? Planning starts at the trip question, with a "Going with friends? Invite" card. The trip question shows Trip and Budget, and cravings and vibe sit under More. The trip is a real filter now: places that fit a trip someone picked (all places if none do), so the counts and "other options" are honest. The Where map has no area labels, and its dots and count only show places that fit the trip.
- **Live tropas:** each shared tropa has a Supabase Realtime broadcast channel (`tropa-<code>`). When a phone saves a change or someone joins, it sends a "poke" with no data, and every phone in the tropa pulls right away, wherever it is in the app. Someone new shows as "🎉 Mia joined Squad". The 4-second check still runs while Tropa mode or Your tropas is open (15 s once the live channel is up) as a fallback.
- **Tropa roles:** `tropas.owner` is the member who made the tropa (existing tropas: their first member). Only the owner removes people, adds people by hand, renames, or marks someone not going. Everyone else answers only for themselves. The **planner** picks the place (`tropa_planner()`): the owner when they're going, otherwise whoever taps **Plan it** first (`state.planner = {id, at}`, good for 8 hours). Only the planner changes Where or locks or unlocks the pick. `tropa_save` enforces all of this on the server. If the owner leaves, the next member with a phone takes over. Members' list shows 👑 Owner. `phone` on each member tells joined-with-a-phone apart from added-by-hand.
- **I'm set ✓:** in a shared tropa, everyone answers trip and budget (cravings and vibe under More) and taps **I'm set ✓** (`tonight.ready`). Then they see who's ✅ Set and who's ⏳ Deciding. The planner gets **Choose where we meet** once everyone going is set, or **Don't wait, pick now**. Members see "Waiting for X to pick the place", and the locked pick shows up for them live. If the owner isn't going, members see "X isn't going tonight" and a **Plan it** button. A tropa only on your phone (or just you) works as before: answer, then Next.
- **Removing people (fixed):** a removal is queued (`R.drop`) the moment Remove is tapped. It's sent at once and is never undone by a refresh in between (the old way could bring the person back). Each person in Tropa mode's list has a ✕ (owner only): tap once for Remove?, tap again to remove just them. Taps are sent straight away; if a sync round is already running, another one runs as soon as it ends. Other phones get the change through the live poke..
- **No more friends added by hand:** a tropa is only people with Keni on their own phone, who join with the invite link or code. Add friend and From your other tropas are gone, and the + seats open the invite. Hand-added friends are cleared out of every tropa on the phone. On the server, tropa_get no longer returns hand-added rows (there were none left; the check constraint `tropa_members_phone_or_account` now blocks them), tropa_save won't add new ones, and tropa_create only adds the creator..
- **The tropa votes (with a countdown):** in a shared tropa (someone else on their own phone), the planner sets Where, picks 1, 2 or 5 min (2 by default), and taps **Start the vote 🗳️**. Keni's top 4 for the group go to every phone live (`state.vote = { ids, at, ends }`), with a toast and buzz. Everyone taps one, and can change it until the end (`tonight.vote = { s: vote.at, id }`). Voters' faces show on each option, and a countdown ring pulses in the last 10 s. It ends at zero or as soon as everyone going has voted (the planner can End the vote now). Most votes wins; a tie goes to Keni's higher-ranked place; no votes: Keni's top pick. Every phone counts the same, so all show the winner (👑, confetti). The planner's phone locks it in after about 2 s and stores the tally on the lock (`locked.tally`), and the locked card says "🗳️ 3 of 4 voted for it". Pick a different place clears the vote. A tropa that's just you works as before (Find our place).
