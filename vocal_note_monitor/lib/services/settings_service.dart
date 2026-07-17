import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/scale.dart';

class SettingsService extends ChangeNotifier {
  SettingsService() {
    _load();
  }

  AppSettings _settings = AppSettings.defaults;
  AppSettings get settings => _settings;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final scaleIndex = prefs.getInt('scaleIndex') ?? 0;

    _settings = AppSettings(
      volumeThreshold: prefs.getDouble('volumeThreshold') ?? 2.0,
      horizontalZoom: prefs.getDouble('horizontalZoom') ?? 1.0,
      verticalZoom: prefs.getDouble('verticalZoom') ?? 1.0,
      showSemitoneLines: prefs.getBool('showSemitoneLines') ?? true,
      a4Frequency: prefs.getDouble('a4Frequency') ?? 440.0,
      autoScroll: prefs.getBool('autoScroll') ?? false,
      displayTuner: prefs.getBool('displayTuner') ?? true,
      scale: MusicalScale.scales[scaleIndex.clamp(0, MusicalScale.scales.length - 1)],
      pitchColor: Color(prefs.getInt('pitchColor') ?? 0xFFFFEB3B),
      tonicColor: Color(prefs.getInt('tonicColor') ?? 0xFF9E9E9E),
      supertonicColor: Color(prefs.getInt('supertonicColor') ?? 0xFF616161),
      mediantColor: Color(prefs.getInt('mediantColor') ?? 0xFF616161),
      subdominantColor: Color(prefs.getInt('subdominantColor') ?? 0xFF616161),
    );
    notifyListeners();
  }

  Future<void> update(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final scaleIndex = MusicalScale.scales.indexOf(newSettings.scale);

    await prefs.setDouble('volumeThreshold', newSettings.volumeThreshold);
    await prefs.setDouble('horizontalZoom', newSettings.horizontalZoom);
    await prefs.setDouble('verticalZoom', newSettings.verticalZoom);
    await prefs.setBool('showSemitoneLines', newSettings.showSemitoneLines);
    await prefs.setDouble('a4Frequency', newSettings.a4Frequency);
    await prefs.setBool('autoScroll', newSettings.autoScroll);
    await prefs.setBool('displayTuner', newSettings.displayTuner);
    await prefs.setInt('scaleIndex', scaleIndex >= 0 ? scaleIndex : 0);
    await prefs.setInt('pitchColor', newSettings.pitchColor.toARGB32());
    await prefs.setInt('tonicColor', newSettings.tonicColor.toARGB32());
    await prefs.setInt('supertonicColor', newSettings.supertonicColor.toARGB32());
    await prefs.setInt('mediantColor', newSettings.mediantColor.toARGB32());
    await prefs.setInt('subdominantColor', newSettings.subdominantColor.toARGB32());
  }

  Future<void> resetToDefaults() => update(AppSettings.defaults);
}
