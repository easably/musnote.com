import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/ui_text.dart';
import '../services/pitch_service.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({
    super.key,
    required this.state,
    required this.onStop,
    required this.onRecord,
    required this.onPlay,
    required this.onMenu,
  });

  final RecordingState state;
  final VoidCallback onStop;
  final VoidCallback onRecord;
  final VoidCallback onPlay;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleButton(icon: Icons.stop, onPressed: onStop, size: 48),
          const SizedBox(width: 32),
          _CircleButton(
            icon: state == RecordingState.recording
                ? Icons.pause
                : Icons.fiber_manual_record,
            onPressed: onRecord,
            size: 64,
            iconColor: Colors.red,
            borderColor: Colors.white,
            filled: state == RecordingState.recording,
          ),
          const SizedBox(width: 32),
          _CircleButton(icon: Icons.play_arrow, onPressed: onPlay, size: 48),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    this.iconColor = Colors.white,
    this.borderColor,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color iconColor;
  final Color? borderColor;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? iconColor.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(color: borderColor ?? Colors.white54, width: 2),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }
}

void showMonitorActionSheet(
  BuildContext context, {
  VoidCallback? onIdeas,
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      actions: [
        if (onIdeas != null)
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onIdeas();
            },
            child: Text(t(context).monitorIdeas),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: Text(t(context).cancel),
      ),
    ),
  );
}
