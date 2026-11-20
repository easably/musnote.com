#!/usr/bin/env bash
# Notify Bing/Yandex/etc via IndexNow after deploy.
set -euo pipefail

KEY="10c7f88821074ad7a6ea3b7a9ebb3b08"
HOST="https://musnote.com"
KEY_LOCATION="${HOST}/indexnow-${KEY}.txt"
ENDPOINT="https://api.indexnow.org/indexnow"

URLS=(
  "${HOST}/"
  "${HOST}/ru/"
  "${HOST}/de/"
  "${HOST}/sitemap.xml"
  "${HOST}/chords/"
  "${HOST}/chords/chart/"
  "${HOST}/ru/chords/"
  "${HOST}/ru/chords/chart/"
  "${HOST}/de/chords/"
  "${HOST}/de/chords/chart/"
)

echo "Submitting ${#URLS[@]} URLs to IndexNow..."
payload_file="$(mktemp)"
trap 'rm -f "$payload_file"' EXIT

{
  printf '{'
  printf '"host":"%s",' "${HOST#https://}"
  printf '"key":"%s",' "$KEY"
  printf '"keyLocation":"%s",' "$KEY_LOCATION"
  printf '"urlList":['
  for i in "${!URLS[@]}"; do
    printf '"%s"' "${URLS[$i]}"
    if [[ "$i" -lt $((${#URLS[@]} - 1)) ]]; then
      printf ','
    fi
  done
  printf ']}'
} > "$payload_file"

curl -sS -X POST "$ENDPOINT" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data-binary "@${payload_file}"

echo
echo "IndexNow submission finished."
