#!/usr/bin/env bash
# Notify Bing/Yandex/etc via IndexNow after deploy.
set -euo pipefail

KEY="10c7f88821074ad7a6ea3b7a9ebb3b08"
HOST="https://musnote.com"
KEY_LOCATION="${HOST}/indexnow-${KEY}.txt"
ENDPOINT="https://api.indexnow.org/indexnow"

URLS=(
  "${HOST}/"
  "${HOST}/song-to-notes/"
  "${HOST}/ru/"
  "${HOST}/ru/song-to-notes/"
  "${HOST}/de/"
  "${HOST}/de/song-to-notes/"
  "${HOST}/pl/"
  "${HOST}/pl/song-to-notes/"
  "${HOST}/es/"
  "${HOST}/es/song-to-notes/"
  "${HOST}/pt/"
  "${HOST}/pt/song-to-notes/"
  "${HOST}/ja/"
  "${HOST}/ja/song-to-notes/"
  "${HOST}/ko/"
  "${HOST}/ko/song-to-notes/"
  "${HOST}/zh-tw/"
  "${HOST}/zh-tw/song-to-notes/"
  "${HOST}/zh-cn/"
  "${HOST}/zh-cn/song-to-notes/"
  "${HOST}/vi/"
  "${HOST}/vi/song-to-notes/"
  "${HOST}/sitemap.xml"
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
