import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/services/site_tools.dart';

void main() {
  test('russian and german get their piano and chord pages', () {
    expect(sitePathFor('ru', '/piano'), '/ru/piano');
    expect(sitePathFor('de', '/chords/chart/'), '/de/chords/chart/');
    expect(sitePathFor('es', '/piano'), '/piano');
    expect(sitePathFor('ru', '/tools/find-my-octave'), '/tools/find-my-octave');
  });

  test('the app list and other sites leave the window', () {
    expect(siteToolStaysInside(Uri.parse('https://musnote.com/piano?app=1')), isTrue);
    expect(siteToolStaysInside(Uri.parse('https://www.musnote.com/piano')), isTrue);
    expect(siteToolStaysInside(Uri.parse('https://musnote.com/app/')), isFalse);
    expect(siteToolStaysInside(Uri.parse('https://example.com/piano')), isFalse);
  });
}
