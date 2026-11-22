import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/ui_text.dart';
import '../models/recording.dart';
import '../services/recording_store.dart';
import '../services/store_review_service.dart';
import '../strategies/store_review_prompt.dart';
import '../strategies/store_review_strategy.dart';
import '../theme/musnote_theme.dart';
import '../theme/musnote_tokens.g.dart';
import '../widgets/note_sketch.dart';
import '../widgets/store_review_banner.dart';
import 'add_sound_sheet.dart';
import 'musnote_settings_screen.dart';
import 'recording_screen.dart';
import 'tools_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with WidgetsBindingObserver {
  var _bannerVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _leaveBannerIfShowing();
    }
  }

  Future<void> _leaveBannerIfShowing() async {
    if (!_bannerVisible) return;
    final review = context.read<StoreReviewService>();
    if (review.armedRecordingId == null && !review.closing) return;
    await review.consume(StoreReviewCloseKind.leave);
    if (mounted) setState(() => _bannerVisible = false);
  }

  Recording? _armedRecording(RecordingStore store, StoreReviewService review) {
    final id = review.armedRecordingId;
    if (id == null) return null;
    for (final item in store.items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecordingStore>();
    final review = context.watch<StoreReviewService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.fillMissingDurations();
    });
    final items = store.items;
    final armed = _armedRecording(store, review);
    final stillReady = armed != null && armed.hasPlayableNotes;
    if (review.armedRecordingId != null && !stillReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        review.clearArmIfInvalid(recordingStillReady: false);
      });
    }
    final eligible = review.isEligibleToShow(recordingStillReady: stillReady) &&
        storeReviewListingUri() != null;
    final showBanner = keepStoreReviewBannerMounted(
      eligible: eligible,
      closing: review.closing,
    );
    if (eligible && !_bannerVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        review.markSessionShown();
        setState(() => _bannerVisible = true);
      });
    }
    final readyCount = math.max(
      review.lifetimeReadyCount,
      items.where((item) => item.hasPlayableNotes).length,
    );

    return Scaffold(
      backgroundColor: MusnoteColors.surface2,
      appBar: AppBar(
        backgroundColor: MusnoteColors.surface,
        elevation: 0,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Mus', style: TextStyle(color: MusnoteColors.ink)),
              TextSpan(text: 'Note', style: TextStyle(color: MusnoteColors.green600)),
            ],
          ),
          style: MusnoteType.display,
        ),
        actions: [
          IconButton(
            tooltip: t(context).toolsTooltip,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ToolsScreen()),
              );
            },
            icon: const Icon(Icons.grid_view_rounded),
          ),
          IconButton(
            tooltip: t(context).settingsTooltip,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MusnoteSettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 66,
        height: 66,
        child: FloatingActionButton(
          backgroundColor: MusnoteColors.green500,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () => showAddSoundSheet(context),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      body: MusnotePage(
        child: items.isEmpty
          ? const _EmptyLibrary()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                Text(
                  t(context).recordingCount(items.length),
                  style: const TextStyle(color: MusnoteColors.muted),
                ),
                const SizedBox(height: 12),
                if (showBanner)
                  StoreReviewBanner(
                    readyCount: readyCount,
                    onClosing: () => review.setClosing(true),
                    onOpenStore: () {
                      // Persist before leaving for the store so a process kill
                      // after tap still counts as rated.
                      review.consume(StoreReviewCloseKind.cta);
                      openAppStoreListing();
                    },
                    onFinished: (kind) async {
                      if (kind == StoreReviewCloseKind.dismiss) {
                        await review.consume(StoreReviewCloseKind.dismiss);
                      } else if (kind == StoreReviewCloseKind.cta) {
                        review.setClosing(false);
                      }
                      if (mounted) setState(() => _bannerVisible = false);
                    },
                  ),
                for (final recording in items) ...[
                  _RecordingCard(recording: recording),
                  const SizedBox(height: 12),
                ],
              ],
            ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.piano, size: 56, color: MusnoteColors.green600),
            const SizedBox(height: 12),
            Text(
              text.emptyTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              text.emptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: MusnoteColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  const _RecordingCard({required this.recording});

  final Recording recording;

  @override
  Widget build(BuildContext context) {
    final selected = recording.selected;
    return Dismissible(
      key: ValueKey(recording.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final yes = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t(context).deleteTitle),
            content: Text(t(context).deleteBody(recording.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t(context).keep),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t(context).delete),
              ),
            ],
          ),
        );
        if (yes == true && context.mounted) {
          await context.read<RecordingStore>().delete(recording.id);
        }
        return yes == true;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: MusnoteColors.danger,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Material(
        color: MusnoteColors.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecordingScreen(recordingId: recording.id),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MusnoteColors.line),
              boxShadow: MusnoteTokens.shadowSoft,
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _SourceBadge(source: recording.source),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recording.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${sourceName(t(context), recording.source)} · ${formatDuration(recording.duration)} · ${formatRecordingDate(recording.createdAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: MusnoteColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      status: recording.status,
                      quiet: recording.status == RecordingStatus.ready &&
                          !recording.hasPlayableNotes,
                    ),
                  ],
                ),
                if (recording.status == RecordingStatus.ready && selected != null) ...[
                  const SizedBox(height: 12),
                  NoteSketch(notes: selected.notes),
                ] else if (recording.status == RecordingStatus.raw) ...[
                  const SizedBox(height: 12),
                  const _DashedHint(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final RecordingSource source;

  @override
  Widget build(BuildContext context) {
    final icon = switch (source) {
      RecordingSource.mic => Icons.mic_none,
      RecordingSource.file => Icons.insert_drive_file_outlined,
    };
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: MusnoteColors.green50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: MusnoteColors.green700),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.quiet});

  final RecordingStatus status;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    final (label, color, bg) = quiet
        ? (text.noNotes, MusnoteColors.muted, const Color(0xFFF1F4F3))
        : switch (status) {
            RecordingStatus.raw => (text.statusRaw, MusnoteColors.muted, const Color(0xFFF1F4F3)),
            RecordingStatus.reading => (text.statusReading, const Color(0xFF92400E), const Color(0xFFFEF3C7)),
            RecordingStatus.ready => (text.statusReady, MusnoteColors.green700, MusnoteColors.green50),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _DashedHint extends StatelessWidget {
  const _DashedHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MusnoteColors.line),
      ),
      child: Text(
        t(context).tapForNotes,
        style: const TextStyle(color: MusnoteColors.muted),
      ),
    );
  }
}
