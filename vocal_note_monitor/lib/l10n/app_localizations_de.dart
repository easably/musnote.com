// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settings => 'Einstellungen';

  @override
  String get noteNames => 'Notennamen';

  @override
  String get noteLetters => 'C D E';

  @override
  String get noteSolfege => 'До Ре Ми';

  @override
  String get about => 'Über die App';

  @override
  String get version => 'Version';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get writeUs => 'Schreib uns';

  @override
  String get howItWorks => 'So funktioniert\'s';

  @override
  String get language => 'Sprache';

  @override
  String get languageAuto => 'Systemsprache';

  @override
  String languageAutoNamed(String name) {
    return 'Systemsprache ($name)';
  }

  @override
  String get tools => 'Werkzeuge';

  @override
  String get toolsTooltip => 'Werkzeuge';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get toolAudio => 'Audio zu Noten';

  @override
  String get toolAudioHint => 'Aufnahmen auf diesem Telefon';

  @override
  String get toolMonitor => 'Stimm-Monitor';

  @override
  String get toolMonitorHint => 'Tonhöhe live';

  @override
  String get groupInApp => 'In der App';

  @override
  String get groupChords => 'Akkorde';

  @override
  String get groupVoice => 'Stimme';

  @override
  String get toolPiano => 'Gehör: Klavier';

  @override
  String get toolPianoHint => 'Einen Ton hören und finden';

  @override
  String get toolChart => 'Akkordverzeichnis';

  @override
  String get toolChartHint => 'Einen Akkord nachschlagen';

  @override
  String get toolClock => 'Akkorduhr';

  @override
  String get toolClockHint => 'Akkorde im Kreis';

  @override
  String get toolHops => 'Schritte 4+3 / 3+4';

  @override
  String get toolHopsHint => 'In Akkordschritten';

  @override
  String get toolPatterns => 'CFG und iDEA';

  @override
  String get toolPatternsHint => 'Zwei Akkordmuster';

  @override
  String get toolSpeech => 'Audio zu Text';

  @override
  String get toolSpeechHint => 'Wörter aus einer Aufnahme';

  @override
  String get toolSlow => 'Langsame Aussprache';

  @override
  String get toolSlowHint => 'Einen Satz langsamer hören';

  @override
  String get toolOctave => 'Meine Oktave finden';

  @override
  String get toolOctaveHint => 'Der Umfang deiner Stimme';

  @override
  String get toolShadow => 'Satz nachsprechen';

  @override
  String get toolShadowHint => 'Der Stimme nachsprechen';

  @override
  String get webMark => 'Web';

  @override
  String get toolOffline =>
      'Die Seite hat sich nicht geöffnet. Internet nötig.';

  @override
  String get toolRetry => 'Nochmal';

  @override
  String get onbTitle => 'Vom Klang zu Noten auf den Tasten';

  @override
  String get onbLine => '🎙 Klang → ♪ Noten → 🎹 Tasten';

  @override
  String get onbBody =>
      'Nimm einen Klang auf oder wähle eine Datei. Wir lesen die Noten, und du kannst sie auf den Tasten spielen.';

  @override
  String get start => 'Start';

  @override
  String get addSound => 'Klang hinzufügen';

  @override
  String get addFormats =>
      'mp3, wav, m4a, flac, aac, ogg, webm · bis 100 MB · ✓ kostenlos';

  @override
  String get tabRecord => 'Aufnahme';

  @override
  String get tabFiles => 'Dateien';

  @override
  String get tabLibrary => 'Mediathek';

  @override
  String get needSource => 'Andere Quelle nötig?';

  @override
  String get needSourceHint =>
      'Sag uns, woher die Musik kommen soll — wir bauen das Häufigste ein';

  @override
  String get chipYoutube => 'YouTube-Link';

  @override
  String get chipVideo => 'Video aus der Galerie';

  @override
  String get chipOther => 'Anderes…';

  @override
  String get pickFile => 'Datei wählen';

  @override
  String get openFiles => 'Dateien öffnen';

  @override
  String get openingAudio => 'Audio auf dem Telefon wird geöffnet…';

  @override
  String get appleHint =>
      'Apple-Music-Titel sind geschützt und lassen sich nicht öffnen. Eigene Audiodateien und ungeschützte Käufe gehen.';

  @override
  String get noAudioAccess => 'Kein Zugriff auf Audio auf diesem Telefon.';

  @override
  String get libraryEmpty => 'Keine Titel in der Mediathek.';

  @override
  String get libraryDenied => 'Zugriff auf die Mediathek ist aus.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String mailSubject(String chip) {
    return 'MusNote: ich möchte eine Quelle — $chip';
  }

  @override
  String mailBody(String version, String system) {
    return 'App $version ($system)';
  }

  @override
  String get micNeeded => 'Mikrofonzugriff wird gebraucht.';

  @override
  String get stop => 'Stopp';

  @override
  String get recordingWord => 'Aufnahme';

  @override
  String get emptyTitle => 'Noch leer';

  @override
  String get emptyBody =>
      'Tippe auf +, um aufzunehmen oder eine Datei zu wählen.';

  @override
  String get deleteTitle => 'Diese Aufnahme löschen?';

  @override
  String deleteBody(String name) {
    return '„$name“ und die Datei werden vom Telefon gelöscht.';
  }

  @override
  String get keep => 'Behalten';

  @override
  String get delete => 'Löschen';

  @override
  String get statusRaw => 'Nicht verarbeitet';

  @override
  String get statusReading => 'Noten werden gelesen…';

  @override
  String get statusReady => 'Noten fertig';

  @override
  String get tapForNotes => 'Tippen, um die Noten zu holen';

  @override
  String recordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufnahmen · auf diesem Telefon',
      one: '$count Aufnahme · auf diesem Telefon',
    );
    return '$_temp0';
  }

  @override
  String get recordingGone => 'Aufnahme gelöscht';

  @override
  String get serverReads =>
      'Der MusNote-Server liest die Noten und legt sie auf die Tasten. ✓ kostenlos';

  @override
  String get getNotes => 'Noten holen';

  @override
  String get noNotes => 'Keine Noten gefunden';

  @override
  String get stemsHeading => 'Spuren';

  @override
  String get comingSoon => 'Bald: Notenblatt (PDF) und MusicXML';

  @override
  String get reading => 'Noten werden gelesen…';

  @override
  String get playTrainer => 'Im Trainer spielen';

  @override
  String trainerSub(String stem) {
    return '$stem · fallende Noten · dreh das Telefon';
  }

  @override
  String foundNotes(int count, String span, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Noten gefunden · $span · von $low bis $high',
      one: '$count Note gefunden · $span · von $low bis $high',
    );
    return '$_temp0';
  }

  @override
  String stemNotes(int count, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Noten · $low–$high',
      one: '$count Note · $low–$high',
    );
    return '$_temp0';
  }

  @override
  String get take => 'Mitnehmen';

  @override
  String get allStems => 'Alle Spuren';

  @override
  String get trackWord => 'Spur';

  @override
  String get midiTitle => 'MIDI-Datei';

  @override
  String get midiOne => 'GarageBand, MuseScore, Synthesia';

  @override
  String get midiAll => 'Eine Datei, jede Spur eine eigene Stimme';

  @override
  String get pdfTitle => 'Blatt mit Buchstaben';

  @override
  String get pdfHint => 'PDF zum Drucken · C E G…';

  @override
  String get txtTitle => 'Noten als Text';

  @override
  String get txtHint => 'In Phrasen, ohne Oktavzahl';

  @override
  String get copyTitle => 'Noten kopieren';

  @override
  String get copyHint => 'In die Zwischenablage';

  @override
  String get copied => 'Noten kopiert';

  @override
  String get buildFailed => 'Datei konnte nicht erstellt werden';

  @override
  String get share => 'Teilen';

  @override
  String get saveDownloads => 'In Downloads speichern';

  @override
  String get saveFiles => 'In Dateien sichern';

  @override
  String get sendOut => 'Senden…';

  @override
  String savedAs(String name) {
    return 'Gespeichert: $name';
  }

  @override
  String get saveFailed => 'Datei konnte nicht gespeichert werden';

  @override
  String get playFailed => 'Konnte nicht abspielen';

  @override
  String get first90 => 'Die ersten 90 Sekunden spielen';

  @override
  String get fileFallback => 'aufnahme';

  @override
  String get errType =>
      'Bitte eine mp3-, wav-, m4a-, flac-, aac-, ogg- oder webm-Datei.';

  @override
  String get errTooBig => 'Die Datei ist größer als 100 MB.';

  @override
  String get errEmpty => 'Die Datei ist leer.';

  @override
  String get errNetwork =>
      'Server nicht erreichbar. Prüfe das Netz und versuch es noch einmal.';

  @override
  String get errRead =>
      'Noten konnten nicht gelesen werden. Versuch es noch einmal.';

  @override
  String get errBad => 'Der Server hat eine unerwartete Antwort geschickt.';

  @override
  String get errStems => 'Der Server hat nicht sechs Spuren geschickt.';

  @override
  String get turnPhone => 'Dreh das Telefon';

  @override
  String get turn => 'Drehen';

  @override
  String get tapHint => 'Tippen — Pause, Tempo, Ende';

  @override
  String get stemVocals => 'Gesang';

  @override
  String get stemPiano => 'Klavier';

  @override
  String get stemGuitar => 'Gitarre';

  @override
  String get stemBass => 'Bass';

  @override
  String get stemOther => 'Sonstiges';

  @override
  String get stemDrums => 'Schlagzeug';

  @override
  String get quietDrums => 'Schlagzeug — keine Noten';

  @override
  String get quietSilent => 'zu leise — keine Noten';

  @override
  String get sourceMic => 'Aufnahme';

  @override
  String get sourceFile => 'Datei';

  @override
  String get sourceLibrary => 'Mediathek';

  @override
  String get monitorSaved => 'Aufnahme gespeichert';

  @override
  String get monitorLoaded => 'Aufnahme geöffnet';

  @override
  String get monitorSave => 'Speichern';

  @override
  String get monitorLoad => 'Öffnen';

  @override
  String get monitorIdeas => 'Ideen (Vorschau)';

  @override
  String get cancel => 'Abbrechen';

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
