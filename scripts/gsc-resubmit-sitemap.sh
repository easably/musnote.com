#!/usr/bin/env bash
# Resubmit sitemap + inspect key URLs in Google Search Console.
# Uses ~/.config/google-search-console/cursor-gsc.json (global credentials).
set -euo pipefail

GSC_JSON="${GSC_CONFIG:-$HOME/.config/google-search-console/cursor-gsc.json}"
GSC_PROPERTY_SITE_URL="${GSC_PROPERTY_SITE_URL:-sc-domain:musnote.com}"
SITEMAP_URL="${SITEMAP_URL:-https://musnote.com/sitemap.xml}"

if [[ ! -f "$GSC_JSON" ]]; then
  echo "Missing GSC credentials: $GSC_JSON"
  exit 1
fi

CLIENT_ID="$(python3 -c "import json; print(json.load(open('$GSC_JSON'))['client_id'])")"
CLIENT_SECRET="$(python3 -c "import json; print(json.load(open('$GSC_JSON'))['client_secret'])")"
REFRESH_TOKEN="$(python3 -c "import json; print(json.load(open('$GSC_JSON'))['refresh_token'])")"

URLS=(
  "https://musnote.com/"
  "https://musnote.com/ru/"
  "https://musnote.com/de/"
)

echo "Refreshing OAuth access token..."
TOKEN_JSON="$(curl -sS -X POST "https://oauth2.googleapis.com/token" \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "refresh_token=${REFRESH_TOKEN}" \
  -d "grant_type=refresh_token")"

ACCESS_TOKEN="$(printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('access_token',''))" 2>/dev/null || true)"
if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "Failed to get access token:"
  echo "$TOKEN_JSON"
  exit 1
fi

SITE_ENC="$(python3 -c "import urllib.parse; print(urllib.parse.quote('${GSC_PROPERTY_SITE_URL}', safe=''))")"
SITEMAP_ENC="$(python3 -c "import urllib.parse; print(urllib.parse.quote('${SITEMAP_URL}', safe=''))")"

echo ""
echo "=== Submit sitemap: ${SITEMAP_URL} ==="
SITEMAP_RESP="$(curl -sS -w "\n%{http_code}" -X PUT \
  "https://www.googleapis.com/webmasters/v3/sites/${SITE_ENC}/sitemaps/${SITEMAP_ENC}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}")"
HTTP_CODE="$(printf '%s' "$SITEMAP_RESP" | tail -1)"
BODY="$(printf '%s' "$SITEMAP_RESP" | sed '$d')"
echo "HTTP ${HTTP_CODE}"
[[ -n "$BODY" && "$BODY" != "{}" ]] && echo "$BODY"

echo ""
echo "=== Inspect URLs (read-only; Request indexing is UI-only) ==="
for url in "${URLS[@]}"; do
  echo "--- $url ---"
  INSPECT_BODY="$(python3 -c "import json; print(json.dumps({'inspectionUrl':'''$url''','siteUrl':'''$GSC_PROPERTY_SITE_URL'''}))")"
  curl -sS -X POST \
    "https://searchconsole.googleapis.com/v1/urlInspection/index:inspect" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$INSPECT_BODY" \
    | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('inspectionResult', {}).get('indexStatusResult', {})
print('coverage:', r.get('coverageState'))
print('lastCrawl:', r.get('lastCrawlTime'))
print('robots:', r.get('robotsTxtState') or r.get('pageFetchState'))
print('canonical:', r.get('googleCanonical') or r.get('userCanonical'))
"
  echo
done

echo "Done. For immediate recrawl click Request indexing in GSC URL Inspection for / /ru/ /de/."
