# iskaro-previews

Statické náhľady webov pre prospektov Iskara. Jeden Vercel projekt s wildcard
doménou `*.nahlad.iskaro.sk` — request na `<slug>.nahlad.iskaro.sk` sa cez
host-rewrite vo `vercel.json` servíruje z `previews/<slug>/`.

**Tento repo je čistý výstup.** Negeneruje nič sám — generátor, šablóny aj
DB prístup žijú v `../iskaro-dashboard/scripts/preview/` (zámerne: tu nie sú
žiadne secrets a polomer škody je 1 náhľad). Deploy = `vercel deploy --prod`
z tohto priečinka (spúšťa ho generátor).

## Identita náhľadu — kontrakt (NEPORUŠIŤ)

**1 prospekt = 1 slug = 1 priečinok = 1 URL.** Reťaz je uzavretá z oboch strán:

```
prospects.preview_slug   (DB, unique)  →  "neway-salon-prievidza"
prospects.preview_url                  →  https://neway-salon-prievidza.nahlad.iskaro.sk
previews/<slug>/                       →  statické súbory náhľadu
previews/<slug>/preview.json           →  { prospect_id, company_name, version, … }
```

Slug sa razí RAZ pri prvom vygenerovaní a už sa nemení (outreach e-mail naň
linkuje). Regenerácia prepíše ten istý priečinok a zdvihne `version`.

## Úprava existujúceho náhľadu

1. Lookup v DB podľa mena/URL → `preview_slug` → otvor LEN `previews/<slug>/`.
2. **Pred zápisom over `preview.json.prospect_id`** proti DB záznamu.
   Nikdy nehádať podľa názvov súborov.
3. Hrubá úprava = zmeniť `prospects.preview_instructions` + regenerovať;
   jemná úprava = cielené editácie súborov tu.
4. Commit po každej úprave — git história = changelog pre klienta.

## Anti-fabulácia

Náhľady NIKDY neobsahujú vymyslené údaje (ceny, hodiny, recenzie, adresy).
Čo v `brand_profile` nie je doložené, je v náhľade placeholder „doplní
klient", alebo sekcia chýba. Všetko je `noindex` (hlavička vo `vercel.json`).

## Súvisiace

- Generátor + šablóny: `../iskaro-dashboard/scripts/preview/`
- Brief a architektúra: `../iskaro-dashboard/PREVIEW-GENERATOR-BRIEF.md`
- Ostré klientske weby žijú ÚPLNE inde — tento projekt je len na náhľady.
