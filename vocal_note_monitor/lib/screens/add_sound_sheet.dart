import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/ui_text.dart';
import '../models/recording.dart';
import '../services/recording_store.dart';
import '../theme/musnote_theme.dart';
import 'recorder_screen.dart';
import 'recording_screen.dart';

Future<void> showAddSoundSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: MusnoteType.pageWidth),
    builder: (_) => const AddSoundSheet(),
  );
}

class AddSoundSheet extends StatefulWidget {
  const AddSoundSheet({super.key});

  @override
  State<AddSoundSheet> createState() => _AddSoundSheetState();
}

enum _AddSoundTab { record, files, fromShare }

class _AddSoundSheetState extends State<AddSoundSheet> {
  _AddSoundTab _tab = _AddSoundTab.record;
  String? _error;
  bool _busy = false;

  List<_AddSoundTab> get _tabs => [
        _AddSoundTab.record,
        _AddSoundTab.files,
        if (Platform.isIOS) _AddSoundTab.fromShare,
      ];

  Future<void> _openRecording(Recording recording) async {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => RecordingScreen(recordingId: recording.id),
      ),
    );
  }

  Future<void> _import(File file, RecordingSource kind, {String? name}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final store = context.read<RecordingStore>();
      final recording = await store.importFile(
        source: file,
        kind: kind,
        displayName: name,
      );
      await _openRecording(recording);
    } on RecordingStoreException catch (error) {
      if (mounted) setState(() => _error = shownError(t(context), error.message));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav', 'm4a', 'flac', 'aac', 'ogg', 'webm'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;
    await _import(File(path), RecordingSource.file);
  }

  Future<void> _mail(String chip) async {
    final info = await PackageInfo.fromPlatform();
    final system = Platform.operatingSystem;
    if (!mounted) return;
    final text = t(context);
    final uri = Uri.parse(
      'mailto:support@englishingames.com'
      '?subject=${Uri.encodeComponent(text.mailSubject(chip))}'
      '&body=${Uri.encodeComponent(text.mailBody(info.version, system))}',
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.86;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: MusnoteColors.line,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t(context).addSound,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t(context).addFormats,
                style: const TextStyle(color: MusnoteColors.muted),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedButton<_AddSoundTab>(
              segments: [
                for (final tab in _tabs)
                  ButtonSegment(value: tab, label: Text(_tabLabel(context, tab))),
              ],
              selected: {_tab},
              onSelectionChanged: (value) {
                setState(() {
                  _tab = value.first;
                  _error = null;
                });
              },
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(_error!, style: const TextStyle(color: MusnoteColors.danger)),
            ),
          Expanded(
            child: _busy
                ? const Center(child: CircularProgressIndicator())
                : switch (_tab) {
                    _AddSoundTab.record => _RecordTab(
                        onRecord: () async {
                          final file = await Navigator.of(context).push<File>(
                            MaterialPageRoute(builder: (_) => const RecorderScreen()),
                          );
                          if (file != null && context.mounted) {
                            await _import(file, RecordingSource.mic, name: t(context).recordingWord);
                          }
                        },
                      ),
                    _AddSoundTab.files => _FilesTab(onPick: _pickFile),
                    _AddSoundTab.fromShare => const _FromShareTab(),
                  },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(context).needSource,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  t(context).needSourceHint,
                  style: const TextStyle(color: MusnoteColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final chip in [
                      t(context).chipYoutube,
                      t(context).chipVideo,
                      t(context).chipOther,
                    ])
                      ActionChip(
                        label: Text(chip),
                        onPressed: () => _mail(chip),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTab extends StatelessWidget {
  const _RecordTab({required this.onRecord});

  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onRecord,
        child: Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: MusnoteColors.danger,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 42),
        ),
      ),
    );
  }
}

class _FilesTab extends StatelessWidget {
  const _FilesTab({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPick,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MusnoteColors.line),
                ),
                child: Text(t(context).pickFile),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onPick,
            child: Text(t(context).openFiles),
          ),
        ],
      ),
    );
  }
}

String _tabLabel(BuildContext context, _AddSoundTab tab) {
  final text = t(context);
  return switch (tab) {
    _AddSoundTab.record => text.tabRecord,
    _AddSoundTab.files => text.tabFiles,
    _AddSoundTab.fromShare => text.tabFromShare,
  };
}

/// How to send one recording from Voice Memos through the iOS share sheet.
class _FromShareTab extends StatelessWidget {
  const _FromShareTab();

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    final steps = [text.fromShareStep1, text.fromShareStep2, text.fromShareStep3];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      children: [
        Text(
          text.fromShareTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(text.fromShareBody, style: const TextStyle(color: MusnoteColors.muted)),
        const SizedBox(height: 16),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: MusnoteColors.green100,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: MusnoteColors.green700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(steps[i])),
              ],
            ),
          ),
      ],
    );
  }
}
