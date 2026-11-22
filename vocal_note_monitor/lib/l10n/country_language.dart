/// Languages this app ships, and the old country table.
///
/// The app language now follows the system language list, not the country.
/// `languageForCountry` stays for the site-shaped table and its test.
const appLanguages = {'en', 'ru', 'es', 'de', 'fr', 'it', 'pl'};

const _countryToLang = {
  'PL': 'pl',
  'ES': 'es',
  'MX': 'es',
  'AR': 'es',
  'CO': 'es',
  'CL': 'es',
  'PE': 'es',
  'VE': 'es',
  'UY': 'es',
  'EC': 'es',
  'GT': 'es',
  'CU': 'es',
  'DO': 'es',
  'BO': 'es',
  'PY': 'es',
  'HN': 'es',
  'SV': 'es',
  'NI': 'es',
  'CR': 'es',
  'PA': 'es',
  'BR': 'pt',
  'PT': 'pt',
  'RU': 'ru',
  'BY': 'ru',
  'KZ': 'ru',
  'KG': 'ru',
  'DE': 'de',
  'AT': 'de',
  'JP': 'ja',
  'KR': 'ko',
  'TW': 'zh-tw',
  'HK': 'zh-tw',
  'CN': 'zh-cn',
  'SG': 'zh-cn',
  'VN': 'vi',
  'US': 'en',
  'GB': 'en',
  'AU': 'en',
  'NZ': 'en',
  'IE': 'en',
  'CA': 'en',
  'FR': 'fr',
  'BE': 'fr',
  'LU': 'fr',
  'MC': 'fr',
  'IT': 'it',
  'SM': 'it',
  'CH': 'de',
};

/// First preferred language this app ships, otherwise English.
String languageFromCodes(Iterable<String> languageCodes) {
  for (final code in languageCodes) {
    final short = code.toLowerCase().split(RegExp('[-_]')).first;
    if (appLanguages.contains(short)) return short;
  }
  return 'en';
}

String languageForCountry(String? countryCode) {
  final code = (countryCode ?? '').trim().toUpperCase();
  final lang = _countryToLang[code] ?? 'en';
  if (!appLanguages.contains(lang)) return 'en';
  return lang;
}

const solfegeLanguages = {'ru', 'es', 'fr', 'it', 'pl'};

bool solfegeForLanguage(String languageCode) => solfegeLanguages.contains(languageCode);
