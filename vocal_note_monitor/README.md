# Vocal Note Monitor

Flutter mobile app for real-time vocal pitch tracking and tuning.

## Features

- Live pitch graph with scrolling yellow pitch line
- Current note display with fine-tuning cents gauge
- Record / stop / play controls
- iOS-style action sheet: Save, Load, Settings
- Settings: volume threshold, zoom, calibration (A4), scale, colors, toggles
- Microphone pitch detection with demo simulation fallback

## Run

```bash
cd vocal_note_monitor
flutter pub get
flutter run
```

## Project structure

```
lib/
  app.dart
  main.dart
  models/          # notes, scale, settings, pitch points
  services/        # pitch detection + settings persistence
  screens/         # monitor + settings
  widgets/         # pitch graph, tuner gauge, control bar
```

## Platforms

- Android: microphone permission in `AndroidManifest.xml`
- iOS: `NSMicrophoneUsageDescription` in `Info.plist`
