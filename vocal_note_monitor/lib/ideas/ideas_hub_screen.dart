import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chord_detect_idea_screen.dart';
import 'chord_role_idea_screen.dart';
import 'piano_strip_idea_screen.dart';
import 'progression_idea_screen.dart';
import 'voice_leading_idea_screen.dart';

/// Hub for experimental idea screens.
/// Separate from the main Vocal Note Monitor flow — for evaluation only.
class IdeasHubScreen extends StatelessWidget {
  const IdeasHubScreen({super.key});

  static const _items = <_IdeaItem>[
    _IdeaItem(
      title: 'Chord role',
      subtitle: 'Which chord tone am I singing? (root / 3rd / 5th)',
      badge: 'Idea 1',
      builder: ChordRoleIdeaScreen.new,
    ),
    _IdeaItem(
      title: 'Piano strip',
      subtitle: 'Mini keyboard: chord tones + live voice highlight',
      badge: 'Idea 2',
      builder: PianoStripIdeaScreen.new,
    ),
    _IdeaItem(
      title: 'Detect chord',
      subtitle: 'Guess chord from recent sung pitch classes',
      badge: 'Idea 3',
      builder: ChordDetectIdeaScreen.new,
    ),
    _IdeaItem(
      title: 'Progression practice',
      subtitle: 'I–V–vi–IV style steps with a target chord role',
      badge: 'Idea 4',
      builder: ProgressionIdeaScreen.new,
    ),
    _IdeaItem(
      title: 'Voice leading',
      subtitle: 'Nearest tone hint toward the next chord',
      badge: 'Idea 5',
      builder: VoiceLeadingIdeaScreen.new,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Ideas (preview)'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A3A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'These screens are prototypes for evaluation only. '
              'They do not change the main monitor, settings, or recording flow.',
              style: TextStyle(color: Colors.white70, height: 1.35),
            ),
          ),
          const SizedBox(height: 16),
          ..._items.map((item) => _IdeaTile(item: item)),
        ],
      ),
    );
  }
}

class _IdeaItem {
  const _IdeaItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Widget Function() builder;
}

class _IdeaTile extends StatelessWidget {
  const _IdeaTile({required this.item});

  final _IdeaItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.subtitle,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.badge,
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontSize: 12,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
        onTap: () {
          Navigator.of(
            context,
          ).push(CupertinoPageRoute<void>(builder: (_) => item.builder()));
        },
      ),
    );
  }
}
