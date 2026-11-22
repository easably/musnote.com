// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get settings => 'Ustawienia';

  @override
  String get noteNames => 'Nazwy nut';

  @override
  String get noteLetters => 'C D E';

  @override
  String get noteSolfege => 'До Ре Ми';

  @override
  String get about => 'O aplikacji';

  @override
  String get version => 'Wersja';

  @override
  String get privacy => 'Polityka prywatności';

  @override
  String get writeUs => 'Napisz do nas';

  @override
  String get howItWorks => 'Jak to działa';

  @override
  String get language => 'Język';

  @override
  String get languageAuto => 'Język systemu';

  @override
  String languageAutoNamed(String name) {
    return 'Język systemu ($name)';
  }

  @override
  String get tools => 'Narzędzia';

  @override
  String get toolsTooltip => 'Narzędzia';

  @override
  String get settingsTooltip => 'Ustawienia';

  @override
  String get toolAudio => 'Audio na nuty';

  @override
  String get toolAudioHint => 'Nagrania na tym telefonie';

  @override
  String get toolMonitor => 'Monitor głosu';

  @override
  String get toolMonitorHint => 'Wysokość głosu na żywo';

  @override
  String get groupInApp => 'W aplikacji';

  @override
  String get groupChords => 'Akordy';

  @override
  String get groupVoice => 'Głos';

  @override
  String get toolPiano => 'Słuch: fortepian';

  @override
  String get toolPianoHint => 'Usłyszeć nutę i znaleźć ją';

  @override
  String get toolChart => 'Tabela akordów';

  @override
  String get toolChartHint => 'Znaleźć akord';

  @override
  String get toolClock => 'Zegar akordów';

  @override
  String get toolClockHint => 'Akordy po kole';

  @override
  String get toolHops => 'Kroki 4+3 / 3+4';

  @override
  String get toolHopsHint => 'Przejścia krokami';

  @override
  String get toolPatterns => 'CFG i iDEA';

  @override
  String get toolPatternsHint => 'Dwa układy akordów';

  @override
  String get toolSpeech => 'Audio na tekst';

  @override
  String get toolSpeechHint => 'Słowa z nagrania';

  @override
  String get toolSlow => 'Wolna wymowa';

  @override
  String get toolSlowHint => 'Usłyszeć frazę wolniej';

  @override
  String get toolOctave => 'Znaleźć swoją oktawę';

  @override
  String get toolOctaveHint => 'Zakres głosu';

  @override
  String get toolShadow => 'Powtórz frazę';

  @override
  String get toolShadowHint => 'Powtórzyć za głosem';

  @override
  String get webMark => 'web';

  @override
  String get toolOffline =>
      'Strona się nie otworzyła. Potrzebny jest internet.';

  @override
  String get toolRetry => 'Spróbuj ponownie';

  @override
  String get onbTitle => 'Z dźwięku w nuty na klawiszach';

  @override
  String get onbLine => '🎙 Dźwięk → ♪ Nuty → 🎹 Klawisze';

  @override
  String get onbBody =>
      'Nagraj dźwięk albo wybierz plik. Odczytamy nuty i będzie je można zagrać na klawiszach.';

  @override
  String get start => 'Zacznij';

  @override
  String get addSound => 'Dodaj dźwięk';

  @override
  String get addFormats =>
      'mp3, wav, m4a, flac, aac, ogg, webm · do 100 MB · ✓ za darmo';

  @override
  String get tabRecord => 'Nagranie';

  @override
  String get tabFiles => 'Pliki';

  @override
  String get tabLibrary => 'Biblioteka';

  @override
  String get needSource => 'Potrzebne inne źródło?';

  @override
  String get needSourceHint =>
      'Napisz, skąd chcesz brać muzykę — dodamy to, o co proszą najczęściej';

  @override
  String get chipYoutube => 'Link do YouTube';

  @override
  String get chipVideo => 'Wideo z galerii';

  @override
  String get chipOther => 'Inne…';

  @override
  String get pickFile => 'Wybierz plik';

  @override
  String get openFiles => 'Otwórz Pliki';

  @override
  String get openingAudio => 'Otwieranie audio na telefonie…';

  @override
  String get appleHint =>
      'Utwory z Apple Music są chronione i się nie otwierają. Własne pliki i niechronione zakupy są w porządku.';

  @override
  String get noAudioAccess => 'Brak dostępu do audio na telefonie.';

  @override
  String get libraryEmpty => 'Brak utworów w bibliotece.';

  @override
  String get libraryDenied => 'Dostęp do biblioteki jest wyłączony.';

  @override
  String get openSettings => 'Otwórz ustawienia';

  @override
  String mailSubject(String chip) {
    return 'MusNote: chcę źródło — $chip';
  }

  @override
  String mailBody(String version, String system) {
    return 'Aplikacja $version ($system)';
  }

  @override
  String get micNeeded => 'Potrzebny jest dostęp do mikrofonu.';

  @override
  String get stop => 'Stop';

  @override
  String get recordingWord => 'Nagranie';

  @override
  String get emptyTitle => 'Na razie pusto';

  @override
  String get emptyBody => 'Stuknij +, żeby nagrać dźwięk albo wybrać plik.';

  @override
  String get deleteTitle => 'Usunąć to nagranie?';

  @override
  String deleteBody(String name) {
    return '„$name” i jego plik zostaną usunięte z telefonu.';
  }

  @override
  String get keep => 'Zostaw';

  @override
  String get delete => 'Usuń';

  @override
  String get statusRaw => 'Nieprzetworzone';

  @override
  String get statusReading => 'Czytamy nuty…';

  @override
  String get statusReady => 'Nuty gotowe';

  @override
  String get tapForNotes => 'Stuknij, żeby dostać nuty';

  @override
  String recordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nagrania · na tym telefonie',
      many: '$count nagrań · na tym telefonie',
      few: '$count nagrania · na tym telefonie',
      one: '$count nagranie · na tym telefonie',
    );
    return '$_temp0';
  }

  @override
  String get recordingGone => 'Nagranie usunięte';

  @override
  String get serverReads =>
      'Serwer MusNote odczyta nuty i położy je na klawiszach. ✓ za darmo';

  @override
  String get getNotes => 'Pobierz nuty';

  @override
  String get noNotes => 'Nie znaleziono nut';

  @override
  String get stemsHeading => 'Ścieżki';

  @override
  String get comingSoon => 'Wkrótce: nuty na pięciolinii (PDF) i MusicXML';

  @override
  String get reading => 'Czytamy nuty…';

  @override
  String get playTrainer => 'Graj w trenerze';

  @override
  String trainerSub(String stem) {
    return '$stem · spadające nuty · obróć telefon';
  }

  @override
  String foundNotes(int count, String span, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znaleziono $count nuty · $span · od $low do $high',
      many: 'Znaleziono $count nut · $span · od $low do $high',
      few: 'Znaleziono $count nuty · $span · od $low do $high',
      one: 'Znaleziono $count nutę · $span · od $low do $high',
    );
    return '$_temp0';
  }

  @override
  String stemNotes(int count, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuty · $low–$high',
      many: '$count nut · $low–$high',
      few: '$count nuty · $low–$high',
      one: '$count nuta · $low–$high',
    );
    return '$_temp0';
  }

  @override
  String get take => 'Zabierz';

  @override
  String get allStems => 'Wszystkie ścieżki';

  @override
  String get trackWord => 'Ścieżka';

  @override
  String get midiTitle => 'Plik MIDI';

  @override
  String get midiOne => 'GarageBand, MuseScore, Synthesia';

  @override
  String get midiAll => 'Jeden plik, każda ścieżka to osobny tor';

  @override
  String get pdfTitle => 'Kartka z literami';

  @override
  String get pdfHint => 'PDF do druku · C E G…';

  @override
  String get txtTitle => 'Nuty jako tekst';

  @override
  String get txtHint => 'W frazach, bez numeru oktawy';

  @override
  String get copyTitle => 'Kopiuj nuty';

  @override
  String get copyHint => 'Do schowka';

  @override
  String get copied => 'Nuty skopiowane';

  @override
  String get buildFailed => 'Nie udało się złożyć pliku';

  @override
  String get share => 'Udostępnij';

  @override
  String get saveDownloads => 'Zapisz w Pobranych';

  @override
  String get saveFiles => 'Zapisz w Plikach';

  @override
  String get sendOut => 'Wyślij…';

  @override
  String savedAs(String name) {
    return 'Zapisano: $name';
  }

  @override
  String get saveFailed => 'Nie udało się zapisać pliku';

  @override
  String get playFailed => 'Nie udało się zagrać';

  @override
  String get first90 => 'Grają pierwsze 90 sekund';

  @override
  String get fileFallback => 'nagranie';

  @override
  String get errType =>
      'Potrzebny plik mp3, wav, m4a, flac, aac, ogg albo webm.';

  @override
  String get errTooBig => 'Plik jest większy niż 100 MB.';

  @override
  String get errEmpty => 'Plik jest pusty.';

  @override
  String get errNetwork =>
      'Nie udało się połączyć z serwerem. Sprawdź sieć i spróbuj jeszcze raz.';

  @override
  String get errRead => 'Nie udało się odczytać nut. Spróbuj jeszcze raz.';

  @override
  String get errBad => 'Serwer odesłał niezrozumiałą odpowiedź.';

  @override
  String get errStems => 'Serwer nie odesłał sześciu ścieżek.';

  @override
  String get turnPhone => 'Obróć telefon';

  @override
  String get turn => 'Obróć';

  @override
  String get tapHint => 'Stuknięcie — pauza, tempo, wyjście';

  @override
  String get stemVocals => 'Głos';

  @override
  String get stemPiano => 'Fortepian';

  @override
  String get stemGuitar => 'Gitara';

  @override
  String get stemBass => 'Bas';

  @override
  String get stemOther => 'Inne';

  @override
  String get stemDrums => 'Perkusja';

  @override
  String get quietDrums => 'perkusja — bez nut';

  @override
  String get quietSilent => 'za cicho — brak nut';

  @override
  String get sourceMic => 'Nagranie';

  @override
  String get sourceFile => 'Plik';

  @override
  String get sourceLibrary => 'Biblioteka';

  @override
  String get monitorSaved => 'Nagranie zapisane';

  @override
  String get monitorLoaded => 'Nagranie otwarte';

  @override
  String get monitorSave => 'Zapisz';

  @override
  String get monitorLoad => 'Otwórz';

  @override
  String get monitorIdeas => 'Pomysły (podgląd)';

  @override
  String get cancel => 'Anuluj';

  @override
  String get langEn => 'English';

  @override
  String get langRu => 'Русский';

  @override
  String get langEs => 'Español';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langFr => 'Français';

  @override
  String get langIt => 'Italiano';

  @override
  String get langPl => 'Polski';
}
