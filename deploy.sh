#!/usr/bin/env bash
# ============================================================================
# Deploy náhľadov do produkcie na *.nahlad.iskaro.sk (jeden príkaz).
#
#   ./deploy.sh            # nasadí aktuálny stav previews/ do produkcie
#   ./deploy.sh --setup    # to isté + pripomenie jednorazové nastavenia
#
# Spúšťa sa z tohto priečinka. Robí to isté ako generátor v dashboarde
# (vercel deploy --prod deployuje CELÝ repo — statika, všetky slugy naraz),
# a hodí sa najmä po ručných úpravách náhľadu počas Dňa ladenia.
#
# JEDNORAZOVÉ nastavenia sa robia vo Vercel dashboarde (CLI `domains add` má
# medzi verziami nestabilný syntax, dashboard je spoľahlivý):
#   1. Settings → Domains → pridaj  *.nahlad.iskaro.sk
#   2. Settings → Deployment Protection → Vercel Authentication →
#      „Only Preview Deployments" (inak je náhľad za login stenou).
# ============================================================================
set -euo pipefail
cd "$(dirname "$0")"

PROJECT="iskaro-previews"
DOMAIN="nahlad.iskaro.sk"

SETUP=0
case "${1:-}" in
  --setup) SETUP=1 ;;
  ""|--deploy) ;;
  -h|--help)
    grep '^#' "$0" | sed 's/^# \{0,1\}//' | head -20
    exit 0
    ;;
  *)
    echo "❌  Neznámy argument: $1  (použi --setup, --help, alebo bez argumentu)" >&2
    exit 2
    ;;
esac

if ! command -v vercel >/dev/null 2>&1; then
  echo "❌  Chýba vercel CLI (npm i -g vercel)." >&2
  exit 1
fi
if ! vercel whoami >/dev/null 2>&1; then
  echo "❌  Nie si prihlásený vo Verceli (vercel login)." >&2
  exit 1
fi

if [[ "$SETUP" == "1" ]]; then
  cat <<EOF
ℹ️   Jednorazové nastavenia sprav vo Vercel dashboarde (spoľahlivejšie než CLI):
    1. Settings → Domains → pridaj  *.$DOMAIN
    2. Settings → Deployment Protection → Vercel Authentication →
       „Only Preview Deployments"
    (projekt: $PROJECT)

EOF
fi

echo "→  Deploy do produkcie…"
vercel deploy --prod

cat <<EOF

✅  Hotovo. Over si náhľad(y), napr.:
    https://test.$DOMAIN
    https://neway-salon-prievidza.$DOMAIN

Ak je stránka za Vercel loginom, vypni Deployment Protection:
    Vercel → projekt $PROJECT → Settings → Deployment Protection

Zápis produkčnej URL do DB (z ../iskaro-dashboard):
    npm run preview:generate -- --id <uuid> --finalize
EOF
