#!/usr/bin/env bash
# Build Vocal Note Monitor IPA and optionally upload to TestFlight.
#
# Usage:
#   ./scripts/ios-testflight.sh              # build IPA + upload
#   ./scripts/ios-testflight.sh --build-only # IPA only
#   ./scripts/ios-testflight.sh --upload-only
#   ./scripts/ios-testflight.sh --no-bump    # keep pubspec build number
#
# Credentials (shared, do not duplicate secrets in this repo):
#   ~/.config/app-store-connect/cursor-asc.json
#   ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8
# Optional override: ASC_CONFIG, or ASC_KEY_ID / ASC_ISSUER_ID / ASC_PRIVATE_KEY_PATH
#
# Bundle ID: com.musnote.vocalNoteMonitor
# Team:      English in Games (C52BX6VAT9) — from ASC config
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT/vocal_note_monitor"
IPA_DIR="$APP_DIR/build/ios/ipa"
EXPORT_PLIST="$APP_DIR/ios/ExportOptions-AppStore.plist"
BUNDLE_ID="com.musnote.vocalNoteMonitor"
DEFAULT_ASC_CONFIG="${HOME}/.config/app-store-connect/cursor-asc.json"

DO_BUILD=1
DO_UPLOAD=1
BUMP=1

usage() {
  cat <<'EOF'
Build Flutter IPA for Vocal Note Monitor and upload to TestFlight.

  ./scripts/ios-testflight.sh              Build + upload (default)
  ./scripts/ios-testflight.sh --build-only IPA only
  ./scripts/ios-testflight.sh --upload-only Upload newest IPA in build/ios/ipa/
  ./scripts/ios-testflight.sh --no-bump    Do not increment pubspec build number

Requires Mac + Xcode + Apple Developer team. ASC API key from global cursor-asc.json.
See plans/ios-publish.md and plans/mobile-direction.md.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --build-only) DO_UPLOAD=0; shift ;;
    --upload-only) DO_BUILD=0; shift ;;
    --no-bump) BUMP=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

expand_home() {
  local value="$1"
  value="${value//\$HOME/$HOME}"
  printf '%s' "${value/#\~/$HOME}"
}

load_asc() {
  if [ -n "${ASC_KEY_ID:-}" ] && [ -n "${ASC_ISSUER_ID:-}" ] && [ -n "${ASC_PRIVATE_KEY_PATH:-}" ]; then
    ASC_PRIVATE_KEY_PATH="$(expand_home "$ASC_PRIVATE_KEY_PATH")"
    DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-${ASC_TEAM_ID:-C52BX6VAT9}}"
    return 0
  fi

  if [ -f "$ROOT/.env.ide" ]; then
    # shellcheck disable=SC1091
    set -a
    source "$ROOT/.env.ide"
    set +a
  fi

  local config
  config="$(expand_home "${ASC_CONFIG:-$DEFAULT_ASC_CONFIG}")"
  if [ ! -f "$config" ]; then
    echo "ASC config not found: $config" >&2
    echo "Expected: ~/.config/app-store-connect/cursor-asc.json" >&2
    return 1
  fi

  eval "$(python3 - "$config" <<'PY'
import json, os, sys
with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)

def exp(v: str) -> str:
    return os.path.expanduser(v.replace("$HOME", os.path.expanduser("~")))

print(f'export ASC_KEY_ID={json.dumps(data["key_id"])}')
print(f'export ASC_ISSUER_ID={json.dumps(data["issuer_id"])}')
print(f'export ASC_PRIVATE_KEY_PATH={json.dumps(exp(data["private_key_path"]))}')
team = data.get("team_id") or "C52BX6VAT9"
print(f'export DEVELOPMENT_TEAM={json.dumps(team)}')
PY
)"
}

resolve_altool() {
  local candidates=(
    "/Applications/Xcode.app/Contents/SharedFrameworks/ContentDelivery.framework/Versions/A/Resources/altool"
    "/Applications/Xcode.app/Contents/SharedFrameworks/ContentDeliveryServices.framework/Versions/A/Frameworks/AppStoreService.framework/Versions/A/Support/altool"
    "/Applications/Xcode.app/Contents/Developer/usr/bin/altool"
  )
  local c
  for c in "${candidates[@]}"; do
    if [ -x "$c" ] && "$c" --help >/dev/null 2>&1; then
      printf '%s' "$c"
      return 0
    fi
  done
  if xcrun --find altool >/dev/null 2>&1; then
    # Broken on some Xcode installs (missing Defaults.properties via xcrun). Prefer absolute paths above.
    printf '%s' "xcrun altool"
    return 0
  fi
  return 1
}

ensure_export_plist() {
  local team="$1"
  mkdir -p "$(dirname "$EXPORT_PLIST")"
  cat > "$EXPORT_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>destination</key>
	<string>export</string>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>teamID</key>
	<string>${team}</string>
	<key>uploadSymbols</key>
	<true/>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>manageAppVersionAndBuildNumber</key>
	<false/>
</dict>
</plist>
EOF
}

bump_pubspec_build() {
  python3 - "$APP_DIR/pubspec.yaml" <<'PY'
from pathlib import Path
import re, sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
m = re.search(r"^version:\s*([0-9.]+)\+(\d+)\s*$", text, re.M)
if not m:
    raise SystemExit(f"Could not parse version: in {path}")
name, build = m.group(1), int(m.group(2)) + 1
new = f"version: {name}+{build}"
text = re.sub(r"^version:\s*[0-9.]+\+\d+\s*$", new, text, count=1, flags=re.M)
path.write_text(text, encoding="utf-8")
print(f"{name}+{build}")
PY
}

read_pubspec_version() {
  python3 - "$APP_DIR/pubspec.yaml" <<'PY'
from pathlib import Path
import re, sys
text = Path(sys.argv[1]).read_text(encoding="utf-8")
m = re.search(r"^version:\s*([0-9.]+)\+(\d+)\s*$", text, re.M)
if not m:
    raise SystemExit("Could not parse version in pubspec.yaml")
print(f"{m.group(1)} {m.group(2)}")
PY
}

newest_ipa() {
  ls -t "$IPA_DIR"/*.ipa 2>/dev/null | head -1 || true
}

echo "==> MusNote iOS → TestFlight"
echo "    App:    $APP_DIR"
echo "    Bundle: $BUNDLE_ID"

load_asc
echo "    Team:   $DEVELOPMENT_TEAM"
echo "    ASC:    $ASC_KEY_ID"

if [ ! -d "$APP_DIR" ]; then
  echo "Flutter app not found: $APP_DIR" >&2
  exit 1
fi

if [ "$DO_BUILD" -eq 1 ]; then
  if ! command -v flutter >/dev/null 2>&1; then
    echo "flutter not found in PATH" >&2
    exit 1
  fi

  BUILD_NAME=""
  BUILD_NUMBER=""
  if [ "$BUMP" -eq 1 ]; then
    echo "==> Bumping pubspec build number"
    VER="$(bump_pubspec_build)"
    BUILD_NAME="${VER%%+*}"
    BUILD_NUMBER="${VER##*+}"
    echo "    version: $VER"
  else
    read -r BUILD_NAME BUILD_NUMBER <<<"$(read_pubspec_version)"
    echo "==> Using pubspec version ${BUILD_NAME}+${BUILD_NUMBER}"
  fi

  ensure_export_plist "$DEVELOPMENT_TEAM"
  echo "==> flutter pub get"
  (
    cd "$APP_DIR"
    flutter pub get
  )

  # Team for Automatic Signing (Flutter/Xcode reads these xcconfigs).
  for xc in "$APP_DIR/ios/Flutter/Debug.xcconfig" "$APP_DIR/ios/Flutter/Release.xcconfig"; do
    if [ -f "$xc" ] && ! grep -q '^DEVELOPMENT_TEAM=' "$xc"; then
      printf '\nDEVELOPMENT_TEAM=%s\n' "$DEVELOPMENT_TEAM" >> "$xc"
    elif [ -f "$xc" ]; then
      sed -i '' "s/^DEVELOPMENT_TEAM=.*/DEVELOPMENT_TEAM=${DEVELOPMENT_TEAM}/" "$xc"
    fi
  done

  echo "==> flutter build ipa (App Store export)"
  (
    cd "$APP_DIR"
    flutter build ipa \
      --release \
      --build-name="$BUILD_NAME" \
      --build-number="$BUILD_NUMBER" \
      --export-options-plist="$EXPORT_PLIST"
  )

  IPA="$(newest_ipa)"
  if [ -z "$IPA" ] || [ ! -f "$IPA" ]; then
    echo "IPA not found under $IPA_DIR" >&2
    exit 1
  fi
  echo "==> Built: $IPA ($(du -h "$IPA" | awk '{print $1}'))"
fi

if [ "$DO_UPLOAD" -eq 1 ]; then
  IPA="$(newest_ipa)"
  if [ -z "$IPA" ] || [ ! -f "$IPA" ]; then
    echo "No IPA to upload in $IPA_DIR" >&2
    echo "Run without --upload-only first, or pass after a successful build." >&2
    exit 1
  fi

  if [ ! -f "$ASC_PRIVATE_KEY_PATH" ]; then
    echo "ASC private key not found: $ASC_PRIVATE_KEY_PATH" >&2
    exit 1
  fi

  mkdir -p "${HOME}/.appstoreconnect/private_keys" "${HOME}/.private_keys"
  DEST_ASC="${HOME}/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
  DEST_PRIV="${HOME}/.private_keys/AuthKey_${ASC_KEY_ID}.p8"
  if [ ! -f "$DEST_ASC" ] || ! cmp -s "$ASC_PRIVATE_KEY_PATH" "$DEST_ASC"; then
    cp "$ASC_PRIVATE_KEY_PATH" "$DEST_ASC"
    chmod 600 "$DEST_ASC"
  fi
  if [ ! -f "$DEST_PRIV" ] || ! cmp -s "$ASC_PRIVATE_KEY_PATH" "$DEST_PRIV"; then
    cp "$ASC_PRIVATE_KEY_PATH" "$DEST_PRIV"
    chmod 600 "$DEST_PRIV"
  fi

  ALTOOL="$(resolve_altool)" || {
    echo "altool not found / not working. Install Xcode Command Line Tools." >&2
    exit 1
  }

  echo "==> Uploading $(basename "$IPA") via altool"
  echo "    tool: $ALTOOL"
  set +e
  if [ "$ALTOOL" = "xcrun altool" ]; then
    UPLOAD_OUT="$(xcrun altool --upload-app --type ios --file "$IPA" \
      --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID" 2>&1)"
    UPLOAD_RC=$?
  else
    UPLOAD_OUT="$("$ALTOOL" --upload-app --type ios --file "$IPA" \
      --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID" 2>&1)"
    UPLOAD_RC=$?
  fi
  set -e
  printf '%s\n' "$UPLOAD_OUT"

  if [ "$UPLOAD_RC" -ne 0 ]; then
    if printf '%s' "$UPLOAD_OUT" | grep -qi "Unable to find Apple ID for Bundle ID\|create this app in App Store Connect"; then
      cat >&2 <<EOF

Upload blocked: App Store Connect has no app card for $BUNDLE_ID yet.
Create it once (API key cannot CREATE apps), then re-run:
  ./scripts/ios-testflight.sh --upload-only

  1. https://appstoreconnect.apple.com/apps → + → New App
  2. Platforms: iOS
  3. Bundle ID: $BUNDLE_ID
  4. Name: Vocal Note Monitor (or MusNote Voice)
  5. Primary language: English (U.S.)
  6. SKU: musnote-vocal-note-monitor

Details: plans/ios-publish.md
EOF
    fi
    exit "$UPLOAD_RC"
  fi

  echo ""
  echo "==> Upload submitted. Apple processing usually takes a few minutes."
  echo "    App Store Connect → TestFlight: https://appstoreconnect.apple.com/apps"
fi

echo "==> Done"
