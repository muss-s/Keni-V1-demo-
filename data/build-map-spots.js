// builds the "map spots" module (OpenStreetMap names around Angeles) and puts it into keni.html, just before the search module
const fs = require('fs');
const dir = __dirname + '/';
const KENI = 'C:/Users/merci/OneDrive/Documents/Projects/Keni app/keni.html';
const data = JSON.parse(fs.readFileSync(dir + 'spots.json', 'utf8'));
data.s = data.s.filter((s) => !/^PUJ\b/i.test(s[0])); // jeepney route points, not places
const json = JSON.stringify(data).replace(/</g, '\\u003c').replace(/\u2028/g, '\\u2028').replace(/\u2029/g, '\\u2029');
const mod = `<script>/* Keni · map spots — named spots around Angeles from OpenStreetMap (© OpenStreetMap contributors, ODbL), fetched 2026-10-13:
   malls, schools, churches, shops and so on. Each is only a name, a pin and a type. They are not Keni listings; they help you find a spot on the map.
   Search over them runs on the device (no outside service). When Keni has a backend, this list moves into its database unchanged. */
window.KENI_SPOTS = ${json};
(() => {
  const K = window.KeniCore, D = window.KENI_SPOTS; if (!K || !D) return;
  const norm = (s) => String(s).normalize('NFD').replace(/[\\u0300-\\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
  // when two spots match equally well, the bigger kind of place comes first (a mall before a shop inside it)
  const BIG = { Mall: 0, Airport: 0, Attraction: 1, Park: 1, Sports: 1, Cinema: 1, Market: 1, School: 1, Transport: 1, Government: 1, Area: 1 };
  let idx = null;
  const build = () => { idx = D.s.map((s) => { const n = norm(s[0]); return { n, w: n.split(' '), name: s[0], pt: [s[1] / 1e5, s[2] / 1e5], e: D.t[s[3]][0], type: D.t[s[3]][1], big: BIG[D.t[s[3]][1]] ?? 2 }; }); };
  function near(a, b) { // small typos still count
    if (a === b) return true; if (a.length < 4) return false;
    const max = a.length >= 7 ? 2 : 1; if (Math.abs(a.length - b.length) > max) return false;
    let prev = Array.from({ length: b.length + 1 }, (_, j) => j);
    for (let i = 1; i <= a.length; i++) { const cur = [i]; for (let j = 1; j <= b.length; j++) cur[j] = Math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1)); prev = cur; }
    return prev[b.length] <= max;
  }
  function find(q, limit = 5) {
    const s = norm(q); if (s.length < 2) return [];
    if (!idx) build();
    const toks = s.split(' '), hits = [];
    for (const o of idx) {
      const r = o.n === s ? 0 : o.n.startsWith(s) ? 1 : o.w.some((w) => w.startsWith(s)) ? 2 : o.n.includes(s) ? 3 : toks.length > 1 && toks.every((t) => o.n.includes(t)) ? 4 : -1;
      if (r >= 0) hits.push({ o, r });
    }
    if (!hits.length && s.length >= 5) for (const o of idx) if (toks.every((t) => o.w.some((w) => near(t, w)))) hits.push({ o, r: 5 });
    // leave out anything that is already a Keni place
    const mine = K.VENUES.map((v) => ({ n: norm(v.name), pt: K.venuePoint(v) }));
    const onKeni = (o) => mine.some((v) => Math.abs(v.pt[0] - o.pt[0]) < 0.0025 && Math.abs(v.pt[1] - o.pt[1]) < 0.0025 && (v.n.includes(o.n) || o.n.includes(v.n)));
    const here = K.areaPt(K.S.area);
    return hits.filter((h) => !onKeni(h.o)).map((h) => ({ ...h, km: K.haversine(here, h.o.pt) })).sort((a, b) => a.r - b.r || a.o.big - b.o.big || a.km - b.km).slice(0, limit)
      .map((h) => ({ name: h.o.name, pt: h.o.pt, e: h.o.e, type: h.o.type, km: Math.round(h.km * 10) / 10, rank: h.r }));
  }
  K.spots = { find, count: D.s.length };
})();
</script>
`;
const MARK = '<script>/* Keni · search — a list drops under the search bar';
let k = fs.readFileSync(KENI, 'utf8');
if (k.includes('window.KENI_SPOTS = ')) { console.log('already there: remove it first'); process.exit(1); }
if (k.split(MARK).length !== 2) { console.log('marker not found exactly once'); process.exit(1); }
fs.writeFileSync(KENI, k.replace(MARK, () => mod + MARK));
console.log('spots module added:', data.s.length, 'spots,', Math.round(mod.length / 1024), 'KB');
