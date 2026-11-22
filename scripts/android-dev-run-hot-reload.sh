#!/usr/bin/env bash
# Debug run of the Flutter app on a phone, or an emulator if no phone is plugged in.
# This is not a release build and does not upload to a store.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/vocal_note_monitor"
cd "$APP"

if ! command -v adb >/dev/null 2>&1; then
  echo "adb is not on PATH" >&2
  exit 1
fi

pick_usb() {
  adb devices -l | awk '
    $2 == "device" && $0 !~ /emulator-/ {
      sdk = ""
      for (i = 1; i <= NF; i++) if ($i ~ /^sdk:/) { split($i, a, ":"); sdk = a[2] }
      if (sdk == "" || sdk + 0 >= 24) print $1
    }
  ' | head -n 1
}

serial="$(pick_usb || true)"
if [[ -z "$serial" ]]; then
  serial="$(adb devices | awk '$1 ~ /^emulator-/ && $2 == "device" { print $1; exit }')"
fi
if [[ -z "$serial" ]]; then
  if command -v flutter >/dev/null 2>&1; then
    flutter emulators --launch "$(flutter emulators | awk 'NR>2 && $1 !~ /^$/{ print $1; exit }')" || true
  fi
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    serial="$(adb devices | awk '$1 ~ /^emulator-/ && $2 == "device" { print $1; exit }')"
    [[ -n "$serial" ]] && break
    sleep 3
  done
fi
if [[ -z "$serial" ]]; then
  echo "No Android phone or emulator is available" >&2
  exit 1
fi

echo "Flutter debug on $serial"
exec flutter run --debug -d "$serial"
