import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/country_language.dart';

/// System language, or one of the seven app languages.
class AppLanguage extends ChangeNotifier with WidgetsBindingObserver {
  static const preferenceKey = 'app_language';
  static const automatic = 'auto';

  String choice = automatic;
  String resolved = 'en';
  var _observing = false;

  Locale get locale => Locale(resolved);

  /// Language the system list would pick, even when the user chose another.
  String get systemLanguage => _systemLanguage();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    choice = prefs.getString(preferenceKey) ?? automatic;
    if (!appLanguages.contains(choice) && choice != automatic) {
      choice = automatic;
    }
    _resolve();
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    notifyListeners();
  }

  Future<void> setChoice(String value) async {
    choice = value;
    _resolve();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(preferenceKey, value);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (choice != automatic) return;
    final next = _systemLanguage();
    if (next == resolved) return;
    resolved = next;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _resolve() {
    resolved = choice == automatic ? _systemLanguage() : choice;
  }

  String _systemLanguage() {
    return languageFromCodes(
      PlatformDispatcher.instance.locales.map((locale) => locale.languageCode),
    );
  }
}
