import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/app.dart';

void main() {
  testWidgets('Monitor screen shows scale and controls', (tester) async {
    await tester.pumpWidget(const VocalNoteMonitorApp());
    await tester.pump();

    expect(find.text('C Major'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });
}
