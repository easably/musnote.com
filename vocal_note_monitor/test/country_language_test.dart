import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/l10n/country_language.dart';

void main() {
  test('country maps to a language this app can show', () {
    expect(languageForCountry('PL'), 'pl');
    expect(languageForCountry('br'), 'en');
    expect(languageForCountry('MX'), 'es');
    expect(languageForCountry('CH'), 'de');
    expect(languageForCountry('US'), 'en');
    expect(languageForCountry('BY'), 'ru');
    expect(languageForCountry('FR'), 'fr');
    expect(languageForCountry(null), 'en');
    expect(languageForCountry(''), 'en');
  });

  test('system language list wins over country', () {
    expect(languageFromCodes(['pl', 'en']), 'pl');
    expect(languageFromCodes(['pt-BR', 'ru']), 'ru');
    expect(languageFromCodes(['ja']), 'en');
    expect(languageFromCodes([]), 'en');
  });
}
