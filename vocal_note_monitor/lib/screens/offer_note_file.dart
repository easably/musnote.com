import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/ui_text.dart';
import '../services/note_files.dart';

const _downloads = MethodChannel('com.musnote.vocalNoteMonitor/downloads');

/// Rectangle of the share icon, captured before the file is written.
/// iPhone uses it to anchor the system share sheet.
Rect? shareButtonOrigin(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize || box.size.isEmpty) return null;
  final rect = box.localToGlobal(Offset.zero) & box.size;
  if (rect.width < 1 || rect.height < 1) return null;
  return rect;
}

/// Save or send. Android saves into Downloads. iPhone saves with the Files picker.
Future<void> offerNoteFile(
  BuildContext context,
  File file,
  NoteFileKind kind, {
  Rect? origin,
}) async {
  final text = t(context);
  origin ??= shareButtonOrigin(context);
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(
              Platform.isAndroid
                  ? t(sheetContext).saveDownloads
                  : t(sheetContext).saveFiles,
            ),
            onTap: () => Navigator.pop(sheetContext, 'save'),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: Text(t(sheetContext).sendOut),
            onTap: () => Navigator.pop(sheetContext, 'send'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || choice == null) return;
  if (choice == 'send') {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeFor(kind))],
      sharePositionOrigin: origin,
    );
    return;
  }
  if (!Platform.isAndroid) {
    try {
      final saved = await FilePicker.platform.saveFile(
        fileName: file.uri.pathSegments.last,
        bytes: await file.readAsBytes(),
        type: FileType.custom,
        allowedExtensions: [extensionFor(kind)],
      );
      if (!context.mounted || saved == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text.savedAs(file.uri.pathSegments.last))),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text.saveFailed)),
      );
    }
    return;
  }
  try {
    final saved = await _downloads.invokeMethod<String>('save', {
      'path': file.path,
      'name': file.uri.pathSegments.last,
      'mime': mimeFor(kind),
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text.savedAs(saved ?? file.uri.pathSegments.last))),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text.saveFailed)),
    );
  }
}
