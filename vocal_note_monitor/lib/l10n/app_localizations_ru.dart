// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settings => 'Настройки';

  @override
  String get noteNames => 'Обозначения нот';

  @override
  String get noteLetters => 'C D E';

  @override
  String get noteSolfege => 'До Ре Ми';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get privacy => 'Политика конфиденциальности';

  @override
  String get writeUs => 'Написать нам';

  @override
  String get howItWorks => 'Как это работает';

  @override
  String get language => 'Язык';

  @override
  String get languageAuto => 'Как в системе';

  @override
  String languageAutoNamed(String name) {
    return 'Как в системе ($name)';
  }

  @override
  String get tools => 'Инструменты';

  @override
  String get toolsTooltip => 'Инструменты';

  @override
  String get settingsTooltip => 'Настройки';

  @override
  String get toolAudio => 'Аудио в ноты';

  @override
  String get toolAudioHint => 'Список записей на этом телефоне';

  @override
  String get toolMonitor => 'Монитор голоса';

  @override
  String get toolMonitorHint => 'Высота голоса вживую';

  @override
  String get groupInApp => 'В приложении';

  @override
  String get groupChords => 'Аккорды';

  @override
  String get groupVoice => 'Голос';

  @override
  String get toolPiano => 'Слух: пианино';

  @override
  String get toolPianoHint => 'Услышать ноту и найти её';

  @override
  String get toolChart => 'Таблица аккордов';

  @override
  String get toolChartHint => 'Найти аккорд';

  @override
  String get toolClock => 'Часы аккордов';

  @override
  String get toolClockHint => 'Аккорды по кругу';

  @override
  String get toolHops => 'Шаги 4+3 / 3+4';

  @override
  String get toolHopsHint => 'Переходы по шагам';

  @override
  String get toolPatterns => 'CFG и iDEA';

  @override
  String get toolPatternsHint => 'Два узора аккордов';

  @override
  String get toolSpeech => 'Аудио в текст';

  @override
  String get toolSpeechHint => 'Слова из записи';

  @override
  String get toolSlow => 'Медленное произношение';

  @override
  String get toolSlowHint => 'Фраза медленнее';

  @override
  String get toolOctave => 'Найти свою октаву';

  @override
  String get toolOctaveHint => 'Диапазон голоса';

  @override
  String get toolShadow => 'Повтор фразы';

  @override
  String get toolShadowHint => 'Повторить за голосом';

  @override
  String get webMark => 'веб';

  @override
  String get toolOffline => 'Страница не открылась. Нужен интернет.';

  @override
  String get toolRetry => 'Повторить';

  @override
  String get onbTitle => 'Из звука — в ноты на клавишах';

  @override
  String get onbLine => '🎙 Звук → ♪ Ноты → 🎹 Клавиши';

  @override
  String get onbBody =>
      'Запишите звук или возьмите файл. Мы прочитаем ноты, и их можно сыграть на клавишах.';

  @override
  String get onbNext => 'Далее';

  @override
  String get onbSkip => 'Пропустить';

  @override
  String get onbSoundTitle => 'Запишите мелодию или выберите файл';

  @override
  String get onbSoundBody =>
      'Пианино, голос, песня целиком — mp3, wav, m4a до 100 МБ.';

  @override
  String get onbTracksTitle => 'Мы находим ноты и делим на дорожки';

  @override
  String get onbTracksBody =>
      'Голос, пианино, бас — у каждой дорожки свои ноты. Бесплатно, на сервере MusNote.';

  @override
  String get onbPlayTitle => 'Играйте вместе и забирайте ноты';

  @override
  String get onbPlayBody =>
      'Ноты падают на клавиши. Поделитесь MIDI, листом с буквами или текстом.';

  @override
  String get start => 'Начать';

  @override
  String get addSound => 'Добавить звук';

  @override
  String get addFormats =>
      'mp3, wav, m4a, flac, aac, ogg, webm · до 100 МБ · ✓ бесплатно';

  @override
  String get tabRecord => 'Запись';

  @override
  String get tabFiles => 'Файлы';

  @override
  String get tabFromShare => 'Поделиться';

  @override
  String get fromShareTitle => 'Из «Диктофона»';

  @override
  String get fromShareBody =>
      'Эти записи остаются в «Диктофоне». Одну можно отправить сюда через «Поделиться». Файл будет m4a, MusNote его уже открывает.';

  @override
  String get fromShareStep1 => 'Откройте запись в «Диктофоне».';

  @override
  String get fromShareStep2 =>
      'Нажмите «Поделиться», затем «Сохранить в Файлы».';

  @override
  String get fromShareStep3 => 'На вкладке «Файлы» выберите эту запись.';

  @override
  String get needSource => 'Нужен другой источник?';

  @override
  String get needSourceHint =>
      'Скажите, откуда вы хотите брать музыку — добавим самое частое';

  @override
  String get chipYoutube => 'YouTube-ссылка';

  @override
  String get chipVideo => 'Видео из галереи';

  @override
  String get chipOther => 'Другое…';

  @override
  String get pickFile => 'Выбрать файл';

  @override
  String get openFiles => 'Открыть «Файлы»';

  @override
  String get openingAudio => 'Открываем аудио на телефоне…';

  @override
  String mailSubject(String chip) {
    return 'MusNote: хочу источник — $chip';
  }

  @override
  String mailBody(String version, String system) {
    return 'Приложение $version ($system)';
  }

  @override
  String get micNeeded => 'Нужен доступ к микрофону.';

  @override
  String get stop => 'Стоп';

  @override
  String get recordingWord => 'Запись';

  @override
  String get emptyTitle => 'Пока пусто';

  @override
  String get emptyBody => 'Нажмите «+», чтобы записать звук или взять файл.';

  @override
  String get deleteTitle => 'Удалить запись?';

  @override
  String deleteBody(String name) {
    return '«$name» и её файл будут удалены с телефона.';
  }

  @override
  String get keep => 'Оставить';

  @override
  String get delete => 'Удалить';

  @override
  String get statusRaw => 'Не обработано';

  @override
  String get statusReading => 'Читаем ноты…';

  @override
  String get statusReady => 'Ноты готовы';

  @override
  String get tapForNotes => 'Нажмите, чтобы получить ноты';

  @override
  String recordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей · хранятся на телефоне',
      many: '$count записей · хранятся на телефоне',
      few: '$count записи · хранятся на телефоне',
      one: '$count запись · хранятся на телефоне',
    );
    return '$_temp0';
  }

  @override
  String get recordingGone => 'Запись удалена';

  @override
  String get serverReads =>
      'Сервер MusNote прочитает ноты и разложит их по клавишам. ✓ бесплатно';

  @override
  String get getNotes => 'Получить ноты';

  @override
  String get noNotes => 'Нот не нашлось';

  @override
  String get stemsHeading => 'Дорожки';

  @override
  String get comingSoon => 'Скоро: партитура на нотном стане (PDF) и MusicXML';

  @override
  String get reading => 'Читаем ноты…';

  @override
  String get playTrainer => 'Играть в тренажёре';

  @override
  String trainerSub(String stem) {
    return '$stem · падающие ноты · поверните телефон';
  }

  @override
  String foundNotes(int count, String span, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count нот · $span · от $low до $high',
      many: 'Найдено $count нот · $span · от $low до $high',
      few: 'Найдено $count ноты · $span · от $low до $high',
      one: 'Найдено $count нота · $span · от $low до $high',
    );
    return '$_temp0';
  }

  @override
  String stemNotes(int count, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нот · $low–$high',
      many: '$count нот · $low–$high',
      few: '$count ноты · $low–$high',
      one: '$count нота · $low–$high',
    );
    return '$_temp0';
  }

  @override
  String get take => 'Забрать';

  @override
  String get allStems => 'Все дорожки';

  @override
  String get trackWord => 'Дорожка';

  @override
  String get midiTitle => 'MIDI-файл';

  @override
  String get midiOne => 'GarageBand, MuseScore, Synthesia';

  @override
  String get midiAll => 'Один файл, каждая дорожка — свой трек';

  @override
  String get pdfTitle => 'Лист с буквами нот';

  @override
  String get pdfHint => 'PDF для печати · C E G…';

  @override
  String get txtTitle => 'Ноты текстом';

  @override
  String get txtHint => 'По фразам, без номера октавы';

  @override
  String get copyTitle => 'Скопировать ноты';

  @override
  String get copyHint => 'В буфер обмена';

  @override
  String get copied => 'Ноты скопированы';

  @override
  String get buildFailed => 'Не удалось собрать файл';

  @override
  String get share => 'Поделиться';

  @override
  String get saveDownloads => 'Сохранить в Загрузки';

  @override
  String get saveFiles => 'Сохранить в Файлы';

  @override
  String get sendOut => 'Отправить…';

  @override
  String savedAs(String name) {
    return 'Сохранено: $name';
  }

  @override
  String get saveFailed => 'Не удалось сохранить файл';

  @override
  String get playFailed => 'Не удалось сыграть';

  @override
  String get first90 => 'Играют первые 90 секунд';

  @override
  String get fileFallback => 'запись';

  @override
  String get errType => 'Нужен файл mp3, wav, m4a, flac, aac, ogg или webm.';

  @override
  String get errTooBig => 'Файл больше 100 МБ.';

  @override
  String get errEmpty => 'Файл пустой.';

  @override
  String get errNetwork =>
      'Не удалось связаться с сервером. Проверьте сеть и повторите.';

  @override
  String get errRead => 'Не удалось прочитать ноты. Повторите.';

  @override
  String get errBad => 'Сервер вернул непонятный ответ.';

  @override
  String get errStems => 'Сервер вернул не шесть дорожек.';

  @override
  String get turnPhone => 'Поверните телефон';

  @override
  String get turn => 'Повернуть';

  @override
  String get tapHint => 'Тап — пауза, скорость, выход';

  @override
  String get stemVocals => 'Голос';

  @override
  String get stemPiano => 'Пианино';

  @override
  String get stemGuitar => 'Гитара';

  @override
  String get stemBass => 'Бас';

  @override
  String get stemOther => 'Другое';

  @override
  String get stemDrums => 'Ударные';

  @override
  String get quietDrums => 'ударные — без нот';

  @override
  String get quietSilent => 'тихо — нот нет';

  @override
  String get sourceMic => 'Запись';

  @override
  String get sourceFile => 'Файл';

  @override
  String get monitorSaved => 'Запись сохранена';

  @override
  String get monitorLoaded => 'Запись открыта';

  @override
  String get monitorSave => 'Сохранить';

  @override
  String get monitorLoad => 'Открыть';

  @override
  String get monitorIdeas => 'Идеи (просмотр)';

  @override
  String get cancel => 'Отмена';

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

  @override
  String storeReviewBannerTitle(int count) {
    return 'Песен с нотами: $count';
  }

  @override
  String get storeReviewBannerSubtitle =>
      'Если MusNote помогает услышать музыку, оставьте короткий отзыв.';

  @override
  String get storeReviewBannerAction => 'Оставить отзыв';

  @override
  String get storeReviewBannerThanks => '✓ Спасибо!';

  @override
  String get storeReviewBannerClose => 'Скрыть';
}
