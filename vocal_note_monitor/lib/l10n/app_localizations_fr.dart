// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settings => 'Réglages';

  @override
  String get noteNames => 'Noms des notes';

  @override
  String get noteLetters => 'C D E';

  @override
  String get noteSolfege => 'До Ре Ми';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get privacy => 'Politique de confidentialité';

  @override
  String get writeUs => 'Nous écrire';

  @override
  String get howItWorks => 'Comment ça marche';

  @override
  String get language => 'Langue';

  @override
  String get languageAuto => 'Langue du système';

  @override
  String languageAutoNamed(String name) {
    return 'Langue du système ($name)';
  }

  @override
  String get tools => 'Outils';

  @override
  String get toolsTooltip => 'Outils';

  @override
  String get settingsTooltip => 'Réglages';

  @override
  String get toolAudio => 'Audio en notes';

  @override
  String get toolAudioHint => 'Enregistrements de ce téléphone';

  @override
  String get toolMonitor => 'Moniteur de voix';

  @override
  String get toolMonitorHint => 'Hauteur de la voix en direct';

  @override
  String get groupInApp => 'Dans l\'application';

  @override
  String get groupChords => 'Accords';

  @override
  String get groupVoice => 'Voix';

  @override
  String get toolPiano => 'Oreille : piano';

  @override
  String get toolPianoHint => 'Entendre une note et la trouver';

  @override
  String get toolChart => 'Tableau d\'accords';

  @override
  String get toolChartHint => 'Chercher un accord';

  @override
  String get toolClock => 'Horloge d\'accords';

  @override
  String get toolClockHint => 'Les accords en cercle';

  @override
  String get toolHops => 'Pas 4+3 / 3+4';

  @override
  String get toolHopsHint => 'Avancer par pas';

  @override
  String get toolPatterns => 'CFG et iDEA';

  @override
  String get toolPatternsHint => 'Deux motifs d\'accords';

  @override
  String get toolSpeech => 'Audio en texte';

  @override
  String get toolSpeechHint => 'Les mots d\'un enregistrement';

  @override
  String get toolSlow => 'Prononciation lente';

  @override
  String get toolSlowHint => 'Entendre une phrase lentement';

  @override
  String get toolOctave => 'Trouver mon octave';

  @override
  String get toolOctaveHint => 'L\'étendue de votre voix';

  @override
  String get toolShadow => 'Répéter une phrase';

  @override
  String get toolShadowHint => 'Répéter après la voix';

  @override
  String get webMark => 'web';

  @override
  String get toolOffline => 'La page ne s\'est pas ouverte. Il faut internet.';

  @override
  String get toolRetry => 'Réessayer';

  @override
  String get onbTitle => 'Du son aux notes sur les touches';

  @override
  String get onbLine => '🎙 Son → ♪ Notes → 🎹 Touches';

  @override
  String get onbBody =>
      'Enregistrez un son ou choisissez un fichier. Nous lisons les notes, et vous pouvez les jouer sur les touches.';

  @override
  String get start => 'Commencer';

  @override
  String get addSound => 'Ajouter un son';

  @override
  String get addFormats =>
      'mp3, wav, m4a, flac, aac, ogg, webm · jusqu’à 100 Mo · ✓ gratuit';

  @override
  String get tabRecord => 'Enregistrer';

  @override
  String get tabFiles => 'Fichiers';

  @override
  String get tabLibrary => 'Médiathèque';

  @override
  String get needSource => 'Une autre source ?';

  @override
  String get needSourceHint =>
      'Dites-nous d’où vous voulez prendre la musique — nous ajouterons le plus demandé';

  @override
  String get chipYoutube => 'Lien YouTube';

  @override
  String get chipVideo => 'Vidéo de la galerie';

  @override
  String get chipOther => 'Autre…';

  @override
  String get pickFile => 'Choisir un fichier';

  @override
  String get openFiles => 'Ouvrir Fichiers';

  @override
  String get openingAudio => 'Ouverture de l’audio du téléphone…';

  @override
  String get appleHint =>
      'Les titres Apple Music sont protégés et ne s’ouvrent pas. Vos fichiers et les achats non protégés conviennent.';

  @override
  String get noAudioAccess => 'Pas d’accès à l’audio du téléphone.';

  @override
  String get libraryEmpty => 'Aucun morceau dans la médiathèque.';

  @override
  String get libraryDenied => 'L’accès à la médiathèque est désactivé.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String mailSubject(String chip) {
    return 'MusNote : je veux une source — $chip';
  }

  @override
  String mailBody(String version, String system) {
    return 'Application $version ($system)';
  }

  @override
  String get micNeeded => 'L’accès au micro est nécessaire.';

  @override
  String get stop => 'Stop';

  @override
  String get recordingWord => 'Enregistrement';

  @override
  String get emptyTitle => 'Encore vide';

  @override
  String get emptyBody =>
      'Touchez + pour enregistrer un son ou choisir un fichier.';

  @override
  String get deleteTitle => 'Supprimer cet enregistrement ?';

  @override
  String deleteBody(String name) {
    return '« $name » et son fichier seront supprimés du téléphone.';
  }

  @override
  String get keep => 'Garder';

  @override
  String get delete => 'Supprimer';

  @override
  String get statusRaw => 'Pas encore traité';

  @override
  String get statusReading => 'Lecture des notes…';

  @override
  String get statusReady => 'Notes prêtes';

  @override
  String get tapForNotes => 'Touchez pour obtenir les notes';

  @override
  String recordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enregistrements · gardés sur ce téléphone',
      one: '$count enregistrement · gardé sur ce téléphone',
    );
    return '$_temp0';
  }

  @override
  String get recordingGone => 'Enregistrement supprimé';

  @override
  String get serverReads =>
      'Le serveur MusNote lira les notes et les posera sur les touches. ✓ gratuit';

  @override
  String get getNotes => 'Obtenir les notes';

  @override
  String get noNotes => 'Aucune note trouvée';

  @override
  String get stemsHeading => 'Pistes';

  @override
  String get comingSoon => 'Bientôt : partition (PDF) et MusicXML';

  @override
  String get reading => 'Lecture des notes…';

  @override
  String get playTrainer => 'Jouer dans l’exercice';

  @override
  String trainerSub(String stem) {
    return '$stem · notes qui tombent · tournez le téléphone';
  }

  @override
  String foundNotes(int count, String span, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes trouvées · $span · de $low à $high',
      one: '$count note trouvée · $span · de $low à $high',
    );
    return '$_temp0';
  }

  @override
  String stemNotes(int count, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes · $low–$high',
      one: '$count note · $low–$high',
    );
    return '$_temp0';
  }

  @override
  String get take => 'Exporter';

  @override
  String get allStems => 'Toutes les pistes';

  @override
  String get trackWord => 'Piste';

  @override
  String get midiTitle => 'Fichier MIDI';

  @override
  String get midiOne => 'GarageBand, MuseScore, Synthesia';

  @override
  String get midiAll => 'Un fichier, chaque piste a sa voix';

  @override
  String get pdfTitle => 'Feuille avec les lettres';

  @override
  String get pdfHint => 'PDF à imprimer · C E G…';

  @override
  String get txtTitle => 'Notes en texte';

  @override
  String get txtHint => 'Par phrases, sans numéro d’octave';

  @override
  String get copyTitle => 'Copier les notes';

  @override
  String get copyHint => 'Dans le presse-papiers';

  @override
  String get copied => 'Notes copiées';

  @override
  String get buildFailed => 'Impossible de créer le fichier';

  @override
  String get share => 'Partager';

  @override
  String get saveDownloads => 'Enregistrer dans Téléchargements';

  @override
  String get saveFiles => 'Enregistrer dans Fichiers';

  @override
  String get sendOut => 'Envoyer…';

  @override
  String savedAs(String name) {
    return 'Enregistré : $name';
  }

  @override
  String get saveFailed => 'Impossible d\'enregistrer le fichier';

  @override
  String get playFailed => 'Lecture impossible';

  @override
  String get first90 => 'Les 90 premières secondes jouent';

  @override
  String get fileFallback => 'enregistrement';

  @override
  String get errType =>
      'Il faut un fichier mp3, wav, m4a, flac, aac, ogg ou webm.';

  @override
  String get errTooBig => 'Le fichier dépasse 100 Mo.';

  @override
  String get errEmpty => 'Le fichier est vide.';

  @override
  String get errNetwork =>
      'Serveur injoignable. Vérifiez le réseau et réessayez.';

  @override
  String get errRead => 'Impossible de lire les notes. Réessayez.';

  @override
  String get errBad => 'Le serveur a renvoyé une réponse inattendue.';

  @override
  String get errStems => 'Le serveur n’a pas renvoyé six pistes.';

  @override
  String get turnPhone => 'Tournez le téléphone';

  @override
  String get turn => 'Tourner';

  @override
  String get tapHint => 'Toucher — pause, vitesse, quitter';

  @override
  String get stemVocals => 'Voix';

  @override
  String get stemPiano => 'Piano';

  @override
  String get stemGuitar => 'Guitare';

  @override
  String get stemBass => 'Basse';

  @override
  String get stemOther => 'Autre';

  @override
  String get stemDrums => 'Batterie';

  @override
  String get quietDrums => 'batterie — pas de notes';

  @override
  String get quietSilent => 'trop faible — pas de notes';

  @override
  String get sourceMic => 'Enregistrement';

  @override
  String get sourceFile => 'Fichier';

  @override
  String get sourceLibrary => 'Médiathèque';

  @override
  String get monitorSaved => 'Enregistrement enregistré';

  @override
  String get monitorLoaded => 'Enregistrement ouvert';

  @override
  String get monitorSave => 'Enregistrer';

  @override
  String get monitorLoad => 'Ouvrir';

  @override
  String get monitorIdeas => 'Idées (aperçu)';

  @override
  String get cancel => 'Annuler';

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
