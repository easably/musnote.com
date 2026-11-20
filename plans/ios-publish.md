# iOS: Bundle ID и публикация Vocal Note Monitor

Текущий Bundle ID в проекте: `com.musnote.vocalNoteMonitor`  
(файл: `vocal_note_monitor/ios/Runner.xcodeproj/project.pbxproj`)

## 1) Регистрация App ID — что правда

**Да, часто достаточно один раз собрать/загрузить через Xcode с Automatic Signing:**

1. Открыть `vocal_note_monitor/ios/Runner.xcworkspace` в Xcode (не `.xcodeproj`).
2. Signing & Capabilities → Team = ваш Apple Developer Team.
3. Automatically manage signing = ON.
4. Archive → Upload to App Store Connect / Distribute to TestFlight.

Xcode при этом обычно:
- создаёт **App ID** (`com.musnote.vocalNoteMonitor`) в Certificates, Identifiers & Profiles;
- создаёт provisioning profiles;
- регистрирует устройство (если debug на девайсе).

**Но App Store Connect app (карточка приложения) сама не всегда появляется.**  
Её нужно создать вручную один раз (текущий ASC API key умеет GET/UPDATE apps, но **не CREATE**):

1. [App Store Connect](https://appstoreconnect.apple.com) → My Apps → **+** → New App.
2. Platforms: **iOS**. Bundle ID: `com.musnote.vocalNoteMonitor` (уже есть как XC App ID).
3. Name: `Vocal Note Monitor` (или MusNote Voice). Primary language: English (U.S.).
4. SKU: `musnote-vocal-note-monitor`.

После этого: `./scripts/ios-testflight.sh --upload-only`

Порядок, который вы описали, рабочий:

1. Собрать/залить билд из Xcode (ID регистрируется).
2. Создать новую Application в App Store Connect с этим Bundle ID.
3. Билд появится в TestFlight после обработки Apple (~5–30 мин).

Альтернатива без «сначала Xcode»: создать App ID вручную в  
[developer.apple.com](https://developer.apple.com/account/resources/identifiers/list) → Identifiers → App IDs.

## 2) Как опубликовать Flutter-проект в iOS сейчас

Нужны: Mac, Xcode, аккаунт **Apple Developer Program** ($99/год).

```bash
# Preferred: build IPA + upload to TestFlight (uses global ASC_CONFIG)
./scripts/ios-testflight.sh
./scripts/ios-testflight.sh --build-only   # IPA only
./scripts/ios-testflight.sh --upload-only  # latest IPA

# Manual:
cd vocal_note_monitor
flutter pub get
flutter build ipa
# или открыть Xcode:
open ios/Runner.xcworkspace
```

В Xcode:
1. Select scheme **Runner**, destination **Any iOS Device**.
2. Product → Archive.
3. Distribute App → App Store Connect → Upload.
4. В App Store Connect → TestFlight → дождаться processing → добавить тестировщиков.

Микрофон уже заявлен в `Info.plist` (`NSMicrophoneUsageDescription`) — для pitch detection это обязательно, иначе App Review / runtime отказ.

## 3) Что можно сделать позже (не блокирует TestFlight)

- Сменить Bundle ID, если нужен другой (например `com.musnote.vocalnote`).
- Иконки / splash.
- Privacy Nutrition Labels / App Privacy в Connect.
- Screenshots для App Store (TestFlight их не требует).

## 4) Чего нельзя сделать из этого cloud-агента

Публикация на TestFlight/App Store требует Mac + ваш Apple ID / certificates.  
Здесь можно только держать iOS-проект готовым (Bundle ID, permissions, `flutter build ipa` локально у вас).
