import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/country_language.dart';
import '../models/piano_note.dart';

/// C D E or До Ре Ми. The choice is stored on the phone.
class NoteSpelling extends ChangeNotifier {
  static const _key = 'note_spelling_solfege';

  static const letters = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  static const solfege = [
    'До',
    'До#',
    'Ре',
    'Ре#',
    'Ми',
    'Фа',
    'Фа#',
    'Соль',
    'Соль#',
    'Ля',
    'Ля#',
    'Си',
  ];

  bool solfegeOn = false;
  var _chosen = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _chosen = prefs.containsKey(_key);
    solfegeOn = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  /// Until the user flips the switch, note names follow the app language.
  void followLanguage(String languageCode) {
    if (_chosen) return;
    final next = solfegeForLanguage(languageCode);
    if (next == solfegeOn) return;
    solfegeOn = next;
    notifyListeners();
  }

  Future<void> setSolfege(bool value) async {
    _chosen = true;
    solfegeOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  String name(int midi, {bool withOctave = false}) {
    final pitch = midi % 12;
    final index = pitch < 0 ? pitch + 12 : pitch;
    final syllable = (solfegeOn ? solfege : letters)[index];
    if (!withOctave) return syllable;
    return '$syllable${midi ~/ 12 - 1}';
  }

  /// Same grouping as the site: phrases, then chords in brackets.
  String notesText(List<PianoNote> notes) {
    final list = [...notes]
      ..sort((a, b) => a.start.compareTo(b.start) != 0
          ? a.start.compareTo(b.start)
          : a.midi.compareTo(b.midi));
    final phrases = <List<PianoNote>>[];
    var phrase = <PianoNote>[];
    var phraseEnd = double.negativeInfinity;
    for (final note in list) {
      if (phrase.isNotEmpty && note.start - phraseEnd > 0.6) {
        phrases.add(phrase);
        phrase = [];
        phraseEnd = double.negativeInfinity;
      }
      phrase.add(note);
      if (note.end > phraseEnd) phraseEnd = note.end;
    }
    if (phrase.isNotEmpty) phrases.add(phrase);

    return phrases.map((phrase) {
      final groups = <List<PianoNote>>[];
      for (final note in phrase) {
        if (groups.isEmpty || note.start - groups.last.first.start > 0.04) {
          groups.add([note]);
        } else {
          groups.last.add(note);
        }
      }
      return groups.map((group) {
        final names = (group.toList()..sort((a, b) => a.midi.compareTo(b.midi)))
            .map((note) => name(note.midi))
            .toList();
        return names.length > 1 ? '[${names.join(' ')}]' : names.single;
      }).join(' ');
    }).join('\n');
  }
}
