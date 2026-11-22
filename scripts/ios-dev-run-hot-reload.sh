#!/usr/bin/env bash
# Debug run on a connected iPhone.
# Set IOS_SIMULATOR (for example "iPad Pro 13-inch (M4)"), or leave the phone
# unplugged, and this boots that simulator instead.
# This is not a release build and does not upload to TestFlight.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/vocal_note_monitor"

phone="$(flutter devices --machine | python3 -c '
import json, sys
devices = json.load(sys.stdin)
for device in devices:
    if not device.get("isSupported"):
        continue
    if device.get("targetPlatform") != "ios":
        continue
    if device.get("emulator"):
        continue
    print(device["id"])
    print(device.get("name", ""), file=sys.stderr)
    break
')"

if [[ -z "${IOS_SIMULATOR:-}" && -n "$phone" ]]; then
  echo "Flutter debug on $phone"
  exec flutter run --debug -d "$phone"
fi

name="${IOS_SIMULATOR:-iPad Pro 13-inch (M4)}"
export SIM_NAME="$name"
udid="$(xcrun simctl list devices available -j | python3 -c '
import json, os, sys
wanted = os.environ["SIM_NAME"]
data = json.load(sys.stdin)
for runtime, devices in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue
    for device in devices:
        if device.get("isAvailable") and device.get("name") == wanted:
            print(device["udid"])
            raise SystemExit
sys.stderr.write("No available simulator named %s\n" % wanted)
raise SystemExit(1)
')"

xcrun simctl boot "$udid" || true
if ! open -a Simulator --args -CurrentDeviceUDID "$udid" 2>/dev/null; then
  hub="/Applications/Xcode.app/Contents/Applications/DeviceHub.app"
  if [[ -d "$hub" ]]; then
    open "$hub"
    echo "Simulator.app is not registered; opened Device Hub instead" >&2
  else
    echo "Simulator.app is not registered with Launch Services; the booted device is still used" >&2
  fi
fi
echo "Flutter debug on $name ($udid)"
exec flutter run --debug -d "$udid"
