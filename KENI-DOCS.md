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
