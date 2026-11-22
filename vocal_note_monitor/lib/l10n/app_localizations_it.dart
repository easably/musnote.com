// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get settings => 'Impostazioni';

  @override
  String get noteNames => 'Nomi delle note';

  @override
  String get noteLetters => 'C D E';

  @override
  String get noteSolfege => 'До Ре Ми';

  @override
  String get about => 'Informazioni';

  @override
  String get version => 'Versione';

  @override
  String get privacy => 'Informativa sulla privacy';

  @override
  String get writeUs => 'Scrivici';

  @override
  String get howItWorks => 'Come funziona';

  @override
  String get language => 'Lingua';

  @override
  String get languageAuto => 'Lingua di sistema';

  @override
  String languageAutoNamed(String name) {
    return 'Lingua di sistema ($name)';
  }

  @override
  String get tools => 'Strumenti';

  @override
  String get toolsTooltip => 'Strumenti';

  @override
  String get settingsTooltip => 'Impostazioni';

  @override
  String get toolAudio => 'Audio in note';

  @override
  String get toolAudioHint => 'Registrazioni su questo telefono';

  @override
  String get toolMonitor => 'Monitor della voce';

  @override
  String get toolMonitorHint => 'Altezza della voce dal vivo';

  @override
  String get groupInApp => 'Nell\'app';

  @override
  String get groupChords => 'Accordi';

  @override
  String get groupVoice => 'Voce';

  @override
  String get toolPiano => 'Orecchio: pianoforte';

  @override
  String get toolPianoHint => 'Sentire una nota e trovarla';

  @override
  String get toolChart => 'Tabella degli accordi';

  @override
  String get toolChartHint => 'Cercare un accordo';

  @override
  String get toolClock => 'Orologio degli accordi';

  @override
  String get toolClockHint => 'Accordi in cerchio';

  @override
  String get toolHops => 'Passi 4+3 / 3+4';

  @override
  String get toolHopsHint => 'Spostarsi a passi';

  @override
  String get toolPatterns => 'CFG e iDEA';

  @override
  String get toolPatternsHint => 'Due schemi di accordi';

  @override
  String get toolSpeech => 'Audio in testo';

  @override
  String get toolSpeechHint => 'Parole da una registrazione';

  @override
  String get toolSlow => 'Pronuncia lenta';

  @override
  String get toolSlowHint => 'Sentire una frase lentamente';

  @override
  String get toolOctave => 'Trovare la mia ottava';

  @override
  String get toolOctaveHint => 'L\'estensione della voce';

  @override
  String get toolShadow => 'Ripetere una frase';

  @override
  String get toolShadowHint => 'Ripetere dopo la voce';

  @override
  String get webMark => 'web';

  @override
  String get toolOffline => 'La pagina non si è aperta. Serve internet.';

  @override
  String get toolRetry => 'Riprova';

  @override
  String get onbTitle => 'Dal suono alle note sui tasti';

  @override
  String get onbLine => '🎙 Suono → ♪ Note → 🎹 Tasti';

  @override
  String get onbBody =>
      'Registra un suono o scegli un file. Leggiamo le note e puoi suonarle sui tasti.';

  @override
  String get start => 'Inizia';

  @override
  String get addSound => 'Aggiungi un suono';

  @override
  String get addFormats =>
      'mp3, wav, m4a, flac, aac, ogg, webm · fino a 100 MB · ✓ gratis';

  @override
  String get tabRecord => 'Registra';

  @override
  String get tabFiles => 'File';

  @override
  String get tabLibrary => 'Libreria';

  @override
  String get needSource => 'Ti serve un’altra fonte?';

  @override
  String get needSourceHint =>
      'Dicci da dove vuoi prendere la musica: aggiungeremo la più richiesta';

  @override
  String get chipYoutube => 'Link di YouTube';

  @override
  String get chipVideo => 'Video dalla galleria';

  @override
  String get chipOther => 'Altro…';

  @override
  String get pickFile => 'Scegli un file';

  @override
  String get openFiles => 'Apri File';

  @override
  String get openingAudio => 'Apertura dell’audio sul telefono…';

  @override
  String get appleHint =>
      'I brani di Apple Music sono protetti e non si aprono. Vanno bene i tuoi file e gli acquisti senza protezione.';

  @override
  String get noAudioAccess => 'Nessun accesso all’audio del telefono.';

  @override
  String get libraryEmpty => 'Nessun brano nella libreria.';

  @override
  String get libraryDenied => 'L’accesso alla libreria è disattivato.';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String mailSubject(String chip) {
    return 'MusNote: voglio una fonte — $chip';
  }

  @override
  String mailBody(String version, String system) {
    return 'App $version ($system)';
  }

  @override
  String get micNeeded => 'Serve l’accesso al microfono.';

  @override
  String get stop => 'Stop';

  @override
  String get recordingWord => 'Registrazione';

  @override
  String get emptyTitle => 'Ancora vuoto';

  @override
  String get emptyBody =>
      'Tocca + per registrare un suono o scegliere un file.';

  @override
  String get deleteTitle => 'Eliminare questa registrazione?';

  @override
  String deleteBody(String name) {
    return '“$name” e il suo file saranno eliminati dal telefono.';
  }

  @override
  String get keep => 'Tieni';

  @override
  String get delete => 'Elimina';

  @override
  String get statusRaw => 'Non elaborato';

  @override
  String get statusReading => 'Lettura delle note…';

  @override
  String get statusReady => 'Note pronte';

  @override
  String get tapForNotes => 'Tocca per ottenere le note';

  @override
  String recordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registrazioni · su questo telefono',
      one: '$count registrazione · su questo telefono',
    );
    return '$_temp0';
  }

  @override
  String get recordingGone => 'Registrazione eliminata';

  @override
  String get serverReads =>
      'Il server MusNote leggerà le note e le metterà sui tasti. ✓ gratis';

  @override
  String get getNotes => 'Ottieni le note';

  @override
  String get noNotes => 'Nessuna nota trovata';

  @override
  String get stemsHeading => 'Tracce';

  @override
  String get comingSoon => 'Presto: spartito (PDF) e MusicXML';

  @override
  String get reading => 'Lettura delle note…';

  @override
  String get playTrainer => 'Suona nel trainer';

  @override
  String trainerSub(String stem) {
    return '$stem · note che cadono · ruota il telefono';
  }

  @override
  String foundNotes(int count, String span, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trovate $count note · $span · da $low a $high',
      one: 'Trovata $count nota · $span · da $low a $high',
    );
    return '$_temp0';
  }

  @override
  String stemNotes(int count, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count note · $low–$high',
      one: '$count nota · $low–$high',
    );
    return '$_temp0';
  }

  @override
  String get take => 'Esporta';

  @override
  String get allStems => 'Tutte le tracce';

  @override
  String get trackWord => 'Traccia';

  @override
  String get midiTitle => 'File MIDI';

  @override
  String get midiOne => 'GarageBand, MuseScore, Synthesia';

  @override
  String get midiAll => 'Un file, ogni traccia è una parte';

  @override
  String get pdfTitle => 'Foglio con le lettere';

  @override
  String get pdfHint => 'PDF da stampare · C E G…';

  @override
  String get txtTitle => 'Note in testo';

  @override
  String get txtHint => 'Per frasi, senza numero di ottava';

  @override
  String get copyTitle => 'Copia le note';

  @override
  String get copyHint => 'Negli appunti';

  @override
  String get copied => 'Note copiate';

  @override
  String get buildFailed => 'Impossibile creare il file';

  @override
  String get share => 'Condividi';

  @override
  String get saveDownloads => 'Salva in Download';

  @override
  String get saveFiles => 'Salva in File';

  @override
  String get sendOut => 'Invia…';

  @override
  String savedAs(String name) {
    return 'Salvato: $name';
  }

  @override
  String get saveFailed => 'Impossibile salvare il file';

  @override
  String get playFailed => 'Impossibile riprodurre';

  @override
  String get first90 => 'Suonano i primi 90 secondi';

  @override
  String get fileFallback => 'registrazione';

  @override
  String get errType => 'Serve un file mp3, wav, m4a, flac, aac, ogg o webm.';

  @override
  String get errTooBig => 'Il file supera i 100 MB.';

  @override
  String get errEmpty => 'Il file è vuoto.';

  @override
  String get errNetwork =>
      'Server irraggiungibile. Controlla la rete e riprova.';

  @override
  String get errRead => 'Impossibile leggere le note. Riprova.';

  @override
  String get errBad => 'Il server ha inviato una risposta inattesa.';

  @override
  String get errStems => 'Il server non ha inviato sei tracce.';

  @override
  String get turnPhone => 'Ruota il telefono';

  @override
  String get turn => 'Ruota';

  @override
  String get tapHint => 'Tocca — pausa, velocità, esci';

  @override
  String get stemVocals => 'Voce';

  @override
  String get stemPiano => 'Pianoforte';

  @override
  String get stemGuitar => 'Chitarra';

  @override
  String get stemBass => 'Basso';

  @override
  String get stemOther => 'Altro';

  @override
  String get stemDrums => 'Batteria';

  @override
  String get quietDrums => 'batteria — senza note';

  @override
  String get quietSilent => 'troppo piano — senza note';

  @override
  String get sourceMic => 'Registrazione';

  @override
  String get sourceFile => 'File';

  @override
  String get sourceLibrary => 'Libreria';

  @override
  String get monitorSaved => 'Registrazione salvata';

  @override
  String get monitorLoaded => 'Registrazione aperta';

  @override
  String get monitorSave => 'Salva';

  @override
  String get monitorLoad => 'Apri';

  @override
  String get monitorIdeas => 'Idee (anteprima)';

  @override
  String get cancel => 'Annulla';

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
