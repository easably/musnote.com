import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pitch_service.dart';

/// Shared chrome for Ideas screens — clearly labeled as preview.
class IdeaScaffold extends StatelessWidget {
  const IdeaScaffold({
    super.key,
    required this.title,
    required this.ideaNumber,
    required this.child,
    this.actions,
  });

  final String title;
  final int ideaNumber;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17)),
            Text(
              'Idea $ideaNumber · preview · not part of main monitor',
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
        actions: actions,
      ),
      body: child,
      bottomNavigationBar: const _IdeaMicBar(),
    );
  }
}

class _IdeaMicBar extends StatelessWidget {
  const _IdeaMicBar();

  @override
  Widget build(BuildContext context) {
    final pitch = context.watch<PitchService>();
    final recording = pitch.state == RecordingState.recording;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                pitch.currentNote.frequency > 0
                    ? 'Live: ${pitch.currentNote.displayName}'
                    : 'Live pitch: —',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                if (recording) {
                  pitch.stop();
                } else {
                  pitch.startRecording();
                }
              },
              icon: Icon(
                recording ? Icons.stop : Icons.mic,
                color: recording ? Colors.redAccent : Colors.white,
              ),
              label: Text(recording ? 'Stop' : 'Listen'),
            ),
          ],
        ),
      ),
    );
  }
}
