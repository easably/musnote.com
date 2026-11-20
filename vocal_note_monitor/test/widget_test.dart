import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/app.dart';

void main() {
  testWidgets('Monitor screen shows scale and controls', (tester) async {
    await tester.pumpWidget(const VocalNoteMonitorApp());
    await tester.pump();

    expect(find.text('C Major'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Voice'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    expect(find.text('audio to piano notes'), findsOneWidget);
    expect(find.text('Get notes'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Threshold of volume'), findsOneWidget);
  });
}
