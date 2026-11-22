import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../models/recording.dart';
import '../models/stem_notes.dart';
import 'note_spelling.dart';

/// A4 letter sheet: recording name, date, musnote.com, then one section per stem.
/// Drawn with the phone font so Cyrillic stays readable in black and white.
Future<Uint8List> notesSheetPdf({
  required Recording recording,
  required List<StemNotes> stems,
  required NoteSpelling spelling,
  required String Function(StemNotes stem) titleOf,
}) async {
  const width = 1240.0;
  const height = 1754.0;
  const margin = 80.0;
  final pages = <Uint8List>[];
  var recorder = ui.PictureRecorder();
  var canvas = Canvas(recorder);
  var y = margin;

  void blank() {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    y = margin;
  }

  Future<void> finish() async {
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    picture.dispose();
    if (raw == null) return;
    final rgb = Uint8List(width.toInt() * height.toInt() * 3);
    final pixels = raw.buffer.asUint8List();
    var src = 0;
    var dst = 0;
    while (src < pixels.length) {
      rgb[dst] = pixels[src];
      rgb[dst + 1] = pixels[src + 1];
      rgb[dst + 2] = pixels[src + 2];
      src += 4;
      dst += 3;
    }
    pages.add(rgb);
  }

  Future<void> ensure(double need) async {
    if (y + need <= height - margin) return;
    await finish();
    recorder = ui.PictureRecorder();
    canvas = Canvas(recorder);
    blank();
  }

  void paint(String text, double size, FontWeight weight) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF111111),
          fontSize: size,
          fontWeight: weight,
          height: 1.35,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - margin * 2);
    painter.paint(canvas, Offset(margin, y));
    y += painter.height + 10;
  }

  blank();
  await ensure(90);
  paint(recording.name, 40, FontWeight.w700);
  paint('${formatRecordingDate(recording.createdAt)} · musnote.com', 22, FontWeight.w400);
  y += 18;
  for (final stem in stems) {
    await ensure(80);
    paint(titleOf(stem), 30, FontWeight.w700);
    for (final line in spelling.notesText(stem.notes).split('\n')) {
      await ensure(48);
      paint(line.isEmpty ? ' ' : line, 26, FontWeight.w400);
    }
    y += 20;
  }
  await finish();
  return _assemble(pages, width.toInt(), height.toInt());
}

Uint8List _assemble(List<Uint8List> pages, int width, int height) {
  final chunks = <List<int>>[];
  final offsets = <int>[0];
  var cursor = 0;
  void write(List<int> bytes) {
    chunks.add(bytes);
    cursor += bytes.length;
  }

  final bodies = <List<int>>[];
  final pageNumbers = <int>[];
  for (final rgb in pages) {
    final deflated = ZLibEncoder(level: 6).convert(rgb);
    bodies.add(
      '<< /Type /XObject /Subtype /Image /Width $width /Height $height '
              '/ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode '
              '/Length ${deflated.length} >>\nstream\n'
          .codeUnits +
          deflated +
          '\nendstream\nendobj\n'.codeUnits,
    );
    const content = 'q\n595 0 0 842 0 0 cm\n/Im0 Do\nQ\n';
    bodies.add(
      '<< /Length ${content.length} >>\nstream\n$content\nendstream\nendobj\n'.codeUnits,
    );
    pageNumbers.add(bodies.length + 1);
    bodies.add(const <int>[]);
  }
  final pagesObject = bodies.length + 1;
  for (var i = 0; i < pages.length; i++) {
    final imageObject = i * 3 + 1;
    final contentObject = i * 3 + 2;
    final pageObject = i * 3 + 3;
    bodies[pageObject - 1] =
        '<< /Type /Page /Parent $pagesObject 0 R /MediaBox [0 0 595 842] '
                '/Resources << /XObject << /Im0 $imageObject 0 R >> >> '
                '/Contents $contentObject 0 R >>\nendobj\n'
            .codeUnits;
  }
  bodies.add(
    '<< /Type /Pages /Kids [${pageNumbers.map((n) => '$n 0 R').join(' ')}] /Count ${pageNumbers.length} >>\nendobj\n'
        .codeUnits,
  );
  bodies.add('<< /Type /Catalog /Pages $pagesObject 0 R >>\nendobj\n'.codeUnits);

  write('%PDF-1.4\n'.codeUnits);
  for (var i = 0; i < bodies.length; i++) {
    offsets.add(cursor);
    write('${i + 1} 0 obj\n'.codeUnits);
    write(bodies[i]);
  }
  final xref = cursor;
  final xrefLines = StringBuffer('xref\n0 ${bodies.length + 1}\n0000000000 65535 f \n');
  for (var i = 1; i < offsets.length; i++) {
    xrefLines.write('${offsets[i].toString().padLeft(10, '0')} 00000 n \n');
  }
  write(xrefLines.toString().codeUnits);
  write('trailer << /Size ${bodies.length + 1} /Root ${bodies.length} 0 R >>\n'.codeUnits);
  write('startxref\n$xref\n%%EOF\n'.codeUnits);
  return Uint8List.fromList([for (final chunk in chunks) ...chunk]);
}
