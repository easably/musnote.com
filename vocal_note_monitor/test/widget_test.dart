import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/services/app_language.dart';

void main() {
  test('language choice starts as automatic', () {
    final language = AppLanguage();
    expect(language.choice, AppLanguage.automatic);
    expect(language.resolved, 'en');
  });
}
