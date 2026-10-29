# 2026-10-30: hid every place Keni added (only places added by people stay)

The user asked: "remove the places you added, only the places added by people will remain".
Done by hiding, not deleting: `hidden = true` on 1,452 places (18 full listings + 1,434 small pins), all with `added_by is null`.

7 Keni places were already hidden before this and must stay hidden on undo:
'b-cafeteria-826335','b-chevalier-soccer-ground-471887','b-hakone-coffee-ice-cream-331659','b-mcdonald-s-541545','b-seminary-road-children-s-par-421136','b-spcf-tennis-court-863288','b-totobits-514557'

## Undo (bring them all back)
```sql
update public.places set hidden = false
where added_by is null
  and id not in ('b-cafeteria-826335','b-chevalier-soccer-ground-471887','b-hakone-coffee-ice-cream-331659','b-mcdonald-s-541545','b-seminary-road-children-s-par-421136','b-spcf-tennis-court-863288','b-totobits-514557');
```
