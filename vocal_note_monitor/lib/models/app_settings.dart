import 'package:flutter/material.dart';

import 'scale.dart';

class AppSettings {
  const AppSettings({
    this.volumeThreshold = 2.0,
    this.horizontalZoom = 1.0,
    this.verticalZoom = 1.0,
    this.showSemitoneLines = true,
    this.a4Frequency = 440.0,
    this.autoScroll = false,
    this.displayTuner = true,
    this.scale = MusicalScale.defaultScale,
    this.pitchColor = const Color(0xFFFFEB3B),
    this.tonicColor = const Color(0xFF9E9E9E),
    this.supertonicColor = const Color(0xFF616161),
    this.mediantColor = const Color(0xFF616161),
    this.subdominantColor = const Color(0xFF616161),
  });

  final double volumeThreshold;
  final double horizontalZoom;
  final double verticalZoom;
  final bool showSemitoneLines;
  final double a4Frequency;
  final bool autoScroll;
  final bool displayTuner;
  final MusicalScale scale;
  final Color pitchColor;
  final Color tonicColor;
  final Color supertonicColor;
  final Color mediantColor;
  final Color subdominantColor;

  static const defaults = AppSettings();

  AppSettings copyWith({
    double? volumeThreshold,
    double? horizontalZoom,
    double? verticalZoom,
    bool? showSemitoneLines,
    double? a4Frequency,
    bool? autoScroll,
    bool? displayTuner,
    MusicalScale? scale,
    Color? pitchColor,
    Color? tonicColor,
    Color? supertonicColor,
    Color? mediantColor,
    Color? subdominantColor,
  }) {
    return AppSettings(
      volumeThreshold: volumeThreshold ?? this.volumeThreshold,
      horizontalZoom: horizontalZoom ?? this.horizontalZoom,
      verticalZoom: verticalZoom ?? this.verticalZoom,
      showSemitoneLines: showSemitoneLines ?? this.showSemitoneLines,
      a4Frequency: a4Frequency ?? this.a4Frequency,
      autoScroll: autoScroll ?? this.autoScroll,
      displayTuner: displayTuner ?? this.displayTuner,
      scale: scale ?? this.scale,
      pitchColor: pitchColor ?? this.pitchColor,
      tonicColor: tonicColor ?? this.tonicColor,
      supertonicColor: supertonicColor ?? this.supertonicColor,
      mediantColor: mediantColor ?? this.mediantColor,
      subdominantColor: subdominantColor ?? this.subdominantColor,
    );
  }

  Color colorForScaleDegree(int degree) {
    switch (degree) {
      case 1:
        return tonicColor;
      case 2:
        return supertonicColor;
      case 3:
        return mediantColor;
      case 4:
        return subdominantColor;
      default:
        return pitchColor;
    }
  }
}
