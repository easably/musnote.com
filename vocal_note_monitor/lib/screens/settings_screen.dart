import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/scale.dart';
import '../services/pitch_service.dart';
import '../services/settings_service.dart';
import '../theme/musnote_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.embedded = false});

  /// True when this screen is a bottom tab, so there is no page to close.
  final bool embedded;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _draft;

  @override
  void initState() {
    super.initState();
    _draft = context.read<SettingsService>().settings;
  }

  void _update(AppSettings settings) {
    setState(() => _draft = settings);
    context.read<SettingsService>().update(settings);
    context.read<PitchService>().a4Frequency = settings.a4Frequency;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: MusnoteColors.green500),
        sliderTheme: const SliderThemeData(
          activeTrackColor: MusnoteColors.green500,
          inactiveTrackColor: Color(0xFFE0E0E0),
          thumbColor: Colors.white,
        ),
      ),
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: MusnoteColors.green700,
        ),
        child: CupertinoPageScaffold(
          backgroundColor: Colors.white,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.white,
            middle: const Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            leading: widget.embedded
                ? const SizedBox.shrink()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _update(AppSettings.defaults);
              },
              child: const Text('Default'),
            ),
          ),
          child: Material(
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              children: [
                _SliderSetting(
                  label: 'Threshold of volume',
                  value: _draft.volumeThreshold,
                  min: 0,
                  max: 10,
                  displayValue: _draft.volumeThreshold.toStringAsFixed(2),
                  onChanged: (v) =>
                      _update(_draft.copyWith(volumeThreshold: v)),
                ),
                _SliderSetting(
                  label: 'Horizontal zooming',
                  value: _draft.horizontalZoom,
                  min: 0.25,
                  max: 4,
                  displayValue: _draft.horizontalZoom.toStringAsFixed(2),
                  onChanged: (v) => _update(_draft.copyWith(horizontalZoom: v)),
                ),
                _SliderSetting(
                  label: 'Vertical zooming',
                  value: _draft.verticalZoom,
                  min: 0.25,
                  max: 4,
                  displayValue: _draft.verticalZoom.toStringAsFixed(2),
                  onChanged: (v) => _update(_draft.copyWith(verticalZoom: v)),
                ),
                _ToggleSetting(
                  label: 'Indicate lines of a semitone',
                  value: _draft.showSemitoneLines,
                  onChanged: (v) =>
                      _update(_draft.copyWith(showSemitoneLines: v)),
                ),
                _SliderSetting(
                  label: 'Calibration',
                  value: _draft.a4Frequency,
                  min: 400,
                  max: 480,
                  displayValue: 'A4 = ${_draft.a4Frequency.round()} Hz',
                  onChanged: (v) => _update(_draft.copyWith(a4Frequency: v)),
                ),
                _ToggleSetting(
                  label: 'Auto scroll',
                  value: _draft.autoScroll,
                  onChanged: (v) => _update(_draft.copyWith(autoScroll: v)),
                ),
                _ToggleSetting(
                  label: 'Display tuner',
                  value: _draft.displayTuner,
                  onChanged: (v) => _update(_draft.copyWith(displayTuner: v)),
                ),
                _ScalePicker(
                  scale: _draft.scale,
                  onChanged: (scale) => _update(_draft.copyWith(scale: scale)),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Color',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                _ColorSetting(
                  label: 'Pitch',
                  color: _draft.pitchColor,
                  onChanged: (c) => _update(_draft.copyWith(pitchColor: c)),
                ),
                _ColorSetting(
                  label: '1st Tonic',
                  color: _draft.tonicColor,
                  onChanged: (c) => _update(_draft.copyWith(tonicColor: c)),
                ),
                _ColorSetting(
                  label: '2nd Supertonic',
                  color: _draft.supertonicColor,
                  onChanged: (c) =>
                      _update(_draft.copyWith(supertonicColor: c)),
                ),
                _ColorSetting(
                  label: '3rd Mediant',
                  color: _draft.mediantColor,
                  onChanged: (c) => _update(_draft.copyWith(mediantColor: c)),
                ),
                _ColorSetting(
                  label: '4th Subdominant',
                  color: _draft.subdominantColor,
                  onChanged: (c) =>
                      _update(_draft.copyWith(subdominantColor: c)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Text(
                displayValue,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  const _ToggleSetting({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ScalePicker extends StatelessWidget {
  const _ScalePicker({required this.scale, required this.onChanged});

  final MusicalScale scale;
  final ValueChanged<MusicalScale> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Scale'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${scale.displayName} ',
            style: const TextStyle(color: Colors.grey),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: () => _showScalePicker(context),
    );
  }

  void _showScalePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Scale'),
        actions: MusicalScale.scales
            .map(
              (s) => CupertinoActionSheetAction(
                onPressed: () {
                  onChanged(s);
                  Navigator.pop(context);
                },
                child: Text(s.displayName),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _ColorSetting extends StatelessWidget {
  const _ColorSetting({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  static const _presetColors = [
    Color(0xFFFFEB3B),
    Color(0xFFFF5722),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFF9E9E9E),
    Color(0xFF616161),
    Color(0xFF424242),
    Color(0xFFFFFFFF),
  ];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(context),
        child: Container(
          width: 44,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Color for $label'),
        actions: _presetColors
            .map(
              (c) => CupertinoActionSheetAction(
                onPressed: () {
                  onChanged(c);
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 20,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
