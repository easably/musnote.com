import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/ui_text.dart';
import '../models/recording.dart';
import '../models/stem_notes.dart';
import '../services/note_files.dart';
import '../services/note_spelling.dart';
import '../theme/musnote_theme.dart';
import 'note_preview_screen.dart';
import 'offer_note_file.dart';

/// Export rows on the recording card. A row opens a preview.
/// The share icon offers Save / Send.
class TakeNotes extends StatefulWidget {
  const TakeNotes({super.key, required this.recording});

  final Recording recording;

  @override
  State<TakeNotes> createState() => _TakeNotesState();
}

class _TakeNotesState extends State<TakeNotes> {
  var _all = false;

  List<StemNotes> _stems() {
    if (_all) {
      return widget.recording.stems.where((stem) => stem.playable).toList();
    }
    final selected = widget.recording.selected;
    if (selected == null || !selected.playable) return const [];
    return [selected];
  }

  Future<void> _share(NoteFileKind kind, BuildContext origin) async {
    final shareOrigin = shareButtonOrigin(origin);
    final spelling = context.read<NoteSpelling>();
    final stems = _stems();
    if (stems.isEmpty) {
      _toast(t(context).noNotes);
      return;
    }
    final text = t(context);
    try {
      final file = await writeNoteFile(
        recording: widget.recording,
        stems: stems,
        spelling: spelling,
        kind: kind,
        allStems: _all,
        text: text,
      );
      if (!mounted) return;
      await offerNoteFile(context, file, kind, origin: shareOrigin);
    } catch (_) {
      if (!mounted) return;
      _toast(t(context).buildFailed);
    }
  }

  Future<void> _open(NoteFileKind kind) async {
    final stems = _stems();
    if (stems.isEmpty) {
      _toast(t(context).noNotes);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotePreviewScreen(
          recording: widget.recording,
          stems: stems,
          kind: kind,
          allStems: _all,
        ),
      ),
    );
  }

  Future<void> _copy() async {
    final stems = _stems();
    if (stems.isEmpty) {
      _toast(t(context).noNotes);
      return;
    }
    final spelling = context.read<NoteSpelling>();
    final text = t(context);
    await Clipboard.setData(
      ClipboardData(text: notesPlainText(stems, spelling, text)),
    );
    if (!mounted) return;
    _toast(text.copied);
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    final selected = widget.recording.selected == null
        ? text.trackWord
        : stemName(text, widget.recording.selected!.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text.take.toUpperCase(), style: MusnoteType.section),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(selected)),
            ButtonSegment(value: true, label: Text(text.allStems)),
          ],
          selected: {_all},
          onSelectionChanged: (value) => setState(() => _all = value.first),
        ),
        const SizedBox(height: 8),
        _Row(
          badge: 'MID',
          title: text.midiTitle,
          subtitle: _all ? text.midiAll : text.midiOne,
          onOpen: () => _open(NoteFileKind.midi),
          onShare: (origin) => _share(NoteFileKind.midi, origin),
        ),
        _Row(
          badge: 'PDF',
          title: text.pdfTitle,
          subtitle: text.pdfHint,
          onOpen: () => _open(NoteFileKind.pdf),
          onShare: (origin) => _share(NoteFileKind.pdf, origin),
        ),
        _Row(
          badge: 'TXT',
          title: text.txtTitle,
          subtitle: text.txtHint,
          onOpen: () => _open(NoteFileKind.text),
          onShare: (origin) => _share(NoteFileKind.text, origin),
        ),
        _Row(
          badge: '',
          title: text.copyTitle,
          subtitle: text.copyHint,
          onOpen: _copy,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.onOpen,
    this.onShare,
  });

  final String badge;
  final String title;
  final String subtitle;
  final VoidCallback onOpen;
  final void Function(BuildContext origin)? onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MusnoteColors.green50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: badge.isEmpty
                      ? const Icon(Icons.copy, color: MusnoteColors.green700)
                      : Text(
                          badge,
                          style: const TextStyle(
                            color: MusnoteColors.green700,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        subtitle,
                        style: const TextStyle(color: MusnoteColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (onShare != null)
                  Builder(
                    builder: (buttonContext) => IconButton(
                      tooltip: t(context).share,
                      onPressed: () => onShare!(buttonContext),
                      icon: const Icon(Icons.ios_share, color: MusnoteColors.green700),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
