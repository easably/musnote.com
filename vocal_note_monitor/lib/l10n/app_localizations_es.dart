// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settings => 'Ajustes';

  @override
  String get noteNames => 'Nombres de las notas';

  @override
  String get noteLetters => 'C D E';

  @override
  String get noteSolfege => 'До Ре Ми';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get privacy => 'Política de privacidad';

  @override
  String get writeUs => 'Escríbenos';

  @override
  String get howItWorks => 'Cómo funciona';

  @override
  String get language => 'Idioma';

  @override
  String get languageAuto => 'Idioma del sistema';

  @override
  String languageAutoNamed(String name) {
    return 'Idioma del sistema ($name)';
  }

  @override
  String get tools => 'Herramientas';

  @override
  String get toolsTooltip => 'Herramientas';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get toolAudio => 'Audio a notas';

  @override
  String get toolAudioHint => 'Grabaciones de este teléfono';

  @override
  String get toolMonitor => 'Monitor de voz';

  @override
  String get toolMonitorHint => 'Altura de la voz en vivo';

  @override
  String get groupInApp => 'En la aplicación';

  @override
  String get groupChords => 'Acordes';

  @override
  String get groupVoice => 'Voz';

  @override
  String get toolPiano => 'Oído: piano';

  @override
  String get toolPianoHint => 'Escucha una nota y encuéntrala';

  @override
  String get toolChart => 'Tabla de acordes';

  @override
  String get toolChartHint => 'Busca un acorde';

  @override
  String get toolClock => 'Reloj de acordes';

  @override
  String get toolClockHint => 'Acordes en círculo';

  @override
  String get toolHops => 'Pasos 4+3 / 3+4';

  @override
  String get toolHopsHint => 'Moverse por pasos';

  @override
  String get toolPatterns => 'CFG e iDEA';

  @override
  String get toolPatternsHint => 'Dos patrones de acordes';

  @override
  String get toolSpeech => 'Audio a texto';

  @override
  String get toolSpeechHint => 'Palabras de una grabación';

  @override
  String get toolSlow => 'Pronunciación lenta';

  @override
  String get toolSlowHint => 'Escucha una frase despacio';

  @override
  String get toolOctave => 'Encontrar mi octava';

  @override
  String get toolOctaveHint => 'El rango de tu voz';

  @override
  String get toolShadow => 'Repetir una frase';

  @override
  String get toolShadowHint => 'Repite después de la voz';

  @override
  String get webMark => 'web';

  @override
  String get toolOffline => 'La página no se abrió. Hace falta internet.';

  @override
  String get toolRetry => 'Reintentar';

  @override
  String get onbTitle => 'Del sonido a las notas en el teclado';

  @override
  String get onbLine => '🎙 Sonido → ♪ Notas → 🎹 Teclas';

  @override
  String get onbBody =>
      'Graba un sonido o elige un archivo. Leemos las notas y puedes tocarlas en el teclado.';

  @override
  String get start => 'Empezar';

  @override
  String get addSound => 'Añadir un sonido';

  @override
  String get addFormats =>
      'mp3, wav, m4a, flac, aac, ogg, webm · hasta 100 MB · ✓ gratis';

  @override
  String get tabRecord => 'Grabar';

  @override
  String get tabFiles => 'Archivos';

  @override
  String get tabFromShare => 'Compartir';

  @override
  String get fromShareTitle => 'Desde Notas de voz';

  @override
  String get fromShareBody =>
      'Esas grabaciones se quedan en Notas de voz. Envíe una aquí con Compartir. El archivo es m4a y MusNote ya lo abre.';

  @override
  String get fromShareStep1 => 'Abra la grabación en Notas de voz.';

  @override
  String get fromShareStep2 => 'Pulse Compartir y luego Guardar en Archivos.';

  @override
  String get fromShareStep3 => 'En la pestaña Archivos, elija esa grabación.';



  @override
  String get needSource => '¿Necesitas otra fuente?';

  @override
  String get needSourceHint =>
      'Dinos de dónde quieres sacar la música: añadiremos lo más pedido';

  @override
  String get chipYoutube => 'Enlace de YouTube';

  @override
  String get chipVideo => 'Vídeo de la galería';

  @override
  String get chipOther => 'Otro…';

  @override
  String get pickFile => 'Elegir un archivo';

  @override
  String get openFiles => 'Abrir Archivos';

  @override
  String get openingAudio => 'Abriendo el audio del teléfono…';






  @override
  String mailSubject(String chip) {
    return 'MusNote: quiero una fuente — $chip';
  }

  @override
  String mailBody(String version, String system) {
    return 'Aplicación $version ($system)';
  }

  @override
  String get micNeeded => 'Hace falta acceso al micrófono.';

  @override
  String get stop => 'Parar';

  @override
  String get recordingWord => 'Grabación';

  @override
  String get emptyTitle => 'Todavía vacío';

  @override
  String get emptyBody => 'Pulsa + para grabar un sonido o elegir un archivo.';

  @override
  String get deleteTitle => '¿Eliminar esta grabación?';

  @override
  String deleteBody(String name) {
    return '“$name” y su archivo se eliminarán del teléfono.';
  }

  @override
  String get keep => 'Conservar';

  @override
  String get delete => 'Eliminar';

  @override
  String get statusRaw => 'Sin procesar';

  @override
  String get statusReading => 'Leyendo las notas…';

  @override
  String get statusReady => 'Notas listas';

  @override
  String get tapForNotes => 'Pulsa para obtener las notas';

  @override
  String recordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grabaciones · guardadas en este teléfono',
      one: '$count grabación · guardada en este teléfono',
    );
    return '$_temp0';
  }

  @override
  String get recordingGone => 'Grabación eliminada';

  @override
  String get serverReads =>
      'El servidor de MusNote leerá las notas y las pondrá en el teclado. ✓ gratis';

  @override
  String get getNotes => 'Obtener notas';

  @override
  String get noNotes => 'No se encontraron notas';

  @override
  String get stemsHeading => 'Pistas';

  @override
  String get comingSoon => 'Pronto: partitura (PDF) y MusicXML';

  @override
  String get reading => 'Leyendo las notas…';

  @override
  String get playTrainer => 'Tocar en el entrenador';

  @override
  String trainerSub(String stem) {
    return '$stem · notas que caen · gira el teléfono';
  }

  @override
  String foundNotes(int count, String span, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encontradas $count notas · $span · de $low a $high',
      one: 'Encontrada $count nota · $span · de $low a $high',
    );
    return '$_temp0';
  }

  @override
  String stemNotes(int count, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas · $low–$high',
      one: '$count nota · $low–$high',
    );
    return '$_temp0';
  }

  @override
  String get take => 'Exportar';

  @override
  String get allStems => 'Todas las pistas';

  @override
  String get trackWord => 'Pista';

  @override
  String get midiTitle => 'Archivo MIDI';

  @override
  String get midiOne => 'GarageBand, MuseScore, Synthesia';

  @override
  String get midiAll => 'Un archivo, cada pista es su parte';

  @override
  String get pdfTitle => 'Hoja con letras';

  @override
  String get pdfHint => 'PDF para imprimir · C E G…';

  @override
  String get txtTitle => 'Notas en texto';

  @override
  String get txtHint => 'Por frases, sin número de octava';

  @override
  String get copyTitle => 'Copiar notas';

  @override
  String get copyHint => 'Al portapapeles';

  @override
  String get copied => 'Notas copiadas';

  @override
  String get buildFailed => 'No se pudo crear el archivo';

  @override
  String get share => 'Compartir';

  @override
  String get saveDownloads => 'Guardar en Descargas';

  @override
  String get saveFiles => 'Guardar en Archivos';

  @override
  String get sendOut => 'Enviar…';

  @override
  String savedAs(String name) {
    return 'Guardado: $name';
  }

  @override
  String get saveFailed => 'No se pudo guardar el archivo';

  @override
  String get playFailed => 'No se pudo reproducir';

  @override
  String get first90 => 'Suena los primeros 90 segundos';

  @override
  String get fileFallback => 'grabacion';

  @override
  String get errType =>
      'Hace falta un archivo mp3, wav, m4a, flac, aac, ogg o webm.';

  @override
  String get errTooBig => 'El archivo supera los 100 MB.';

  @override
  String get errEmpty => 'El archivo está vacío.';

  @override
  String get errNetwork =>
      'No se pudo contactar con el servidor. Revisa la red e inténtalo de nuevo.';

  @override
  String get errRead => 'No se pudieron leer las notas. Inténtalo de nuevo.';

  @override
  String get errBad => 'El servidor envió una respuesta inesperada.';

  @override
  String get errStems => 'El servidor no envió seis pistas.';

  @override
  String get turnPhone => 'Gira el teléfono';

  @override
  String get turn => 'Girar';

  @override
  String get tapHint => 'Toca — pausa, velocidad, salir';

  @override
  String get stemVocals => 'Voz';

  @override
  String get stemPiano => 'Piano';

  @override
  String get stemGuitar => 'Guitarra';

  @override
  String get stemBass => 'Bajo';

  @override
  String get stemOther => 'Otro';

  @override
  String get stemDrums => 'Batería';

  @override
  String get quietDrums => 'batería — sin notas';

  @override
  String get quietSilent => 'en silencio — sin notas';

  @override
  String get sourceMic => 'Grabación';

  @override
  String get sourceFile => 'Archivo';


  @override
  String get monitorSaved => 'Grabación guardada';

  @override
  String get monitorLoaded => 'Grabación abierta';

  @override
  String get monitorSave => 'Guardar';

  @override
  String get monitorLoad => 'Abrir';

  @override
  String get monitorIdeas => 'Ideas (vista previa)';

  @override
  String get cancel => 'Cancelar';

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
