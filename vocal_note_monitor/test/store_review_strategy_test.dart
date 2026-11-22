import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/strategies/store_review_strategy.dart';

void main() {
  setUp(StoreReviewSessionGate.reset);

  group('visit qualifies', () {
    test('needs playable notes and two minutes', () {
      expect(
        visitQualifiesForStoreReview(notesReady: false, foregroundSeconds: 200),
        isFalse,
      );
      expect(
        visitQualifiesForStoreReview(notesReady: true, foregroundSeconds: 119),
        isFalse,
      );
      expect(
        visitQualifiesForStoreReview(notesReady: true, foregroundSeconds: 120),
        isTrue,
      );
    });
  });

  group('arm store review banner', () {
    test('arms after the first qualifying visit', () {
      expect(
        shouldArmStoreReviewBanner(
          notesReady: true,
          foregroundSeconds: 120,
          showsUsed: 0,
          alreadyRated: false,
          alreadyArmed: false,
          visitsSinceLastShow: 1,
        ),
        isTrue,
      );
    });

    test('does not arm without notes or with a short visit', () {
      expect(
        shouldArmStoreReviewBanner(
          notesReady: false,
          foregroundSeconds: 200,
          showsUsed: 0,
          alreadyRated: false,
          alreadyArmed: false,
          visitsSinceLastShow: 1,
        ),
        isFalse,
      );
      expect(
        shouldArmStoreReviewBanner(
          notesReady: true,
          foregroundSeconds: 30,
          showsUsed: 0,
          alreadyRated: false,
          alreadyArmed: false,
          visitsSinceLastShow: 1,
        ),
        isFalse,
      );
    });

    test('after a show, waits for two more visits', () {
      expect(
        shouldArmStoreReviewBanner(
          notesReady: true,
          foregroundSeconds: 120,
          showsUsed: 1,
          alreadyRated: false,
          alreadyArmed: false,
          visitsSinceLastShow: 1,
        ),
        isFalse,
      );
      expect(
        shouldArmStoreReviewBanner(
          notesReady: true,
          foregroundSeconds: 120,
          showsUsed: 1,
          alreadyRated: false,
          alreadyArmed: false,
          visitsSinceLastShow: 2,
        ),
        isTrue,
      );
    });

    test('never arms after the CTA or at the show limit', () {
      expect(
        shouldArmStoreReviewBanner(
          notesReady: true,
          foregroundSeconds: 200,
          showsUsed: 0,
          alreadyRated: true,
          alreadyArmed: false,
          visitsSinceLastShow: 5,
        ),
        isFalse,
      );
      expect(
        shouldArmStoreReviewBanner(
          notesReady: true,
          foregroundSeconds: 200,
          showsUsed: storeReviewMaxShows,
          alreadyRated: false,
          alreadyArmed: false,
          visitsSinceLastShow: 5,
        ),
        isFalse,
      );
      expect(
        shouldArmStoreReviewBanner(
          notesReady: true,
          foregroundSeconds: 200,
          showsUsed: 0,
          alreadyRated: false,
          alreadyArmed: true,
          visitsSinceLastShow: 5,
        ),
        isFalse,
      );
    });
  });

  group('show store review banner', () {
    test('shows when armed and ready', () {
      expect(
        shouldShowStoreReviewBanner(
          armed: true,
          recordingStillReady: true,
          showsUsed: 0,
          alreadyRated: false,
          sessionShown: false,
        ),
        isTrue,
      );
    });

    test('hides when rated, session already shown, or notes gone', () {
      expect(
        shouldShowStoreReviewBanner(
          armed: true,
          recordingStillReady: true,
          showsUsed: 0,
          alreadyRated: true,
          sessionShown: false,
        ),
        isFalse,
      );
      expect(
        shouldShowStoreReviewBanner(
          armed: true,
          recordingStillReady: true,
          showsUsed: 0,
          alreadyRated: false,
          sessionShown: true,
        ),
        isFalse,
      );
      expect(
        shouldShowStoreReviewBanner(
          armed: true,
          recordingStillReady: false,
          showsUsed: 0,
          alreadyRated: false,
          sessionShown: false,
        ),
        isFalse,
      );
    });

    test('keeps the strip mounted while it is closing', () {
      expect(
        keepStoreReviewBannerMounted(eligible: false, closing: true),
        isTrue,
      );
      expect(
        keepStoreReviewBannerMounted(eligible: false, closing: false),
        isFalse,
      );
    });
  });

  group('recording visit clock', () {
    test('counts active foreground time', () {
      final clock = RecordingVisitClock();
      final start = DateTime(2026, 11, 22, 12, 0, 0);
      clock.noteActivity(notesReady: true, foreground: true, now: start);
      // Touch again inside the idle window so the clock keeps running.
      clock.noteActivity(
        notesReady: true,
        foreground: true,
        now: start.add(const Duration(seconds: 50)),
      );
      clock.noteActivity(
        notesReady: true,
        foreground: true,
        now: start.add(const Duration(seconds: 90)),
      );
      expect(clock.foregroundSeconds(start.add(const Duration(seconds: 90))), 90);
    });

    test('stops after sixty seconds of idle', () {
      final clock = RecordingVisitClock();
      final start = DateTime(2026, 11, 22, 12, 0, 0);
      clock.noteActivity(notesReady: true, foreground: true, now: start);
      // No new activity; sample far later — only the idle window counts.
      clock.sample(
        notesReady: true,
        foreground: true,
        now: start.add(const Duration(seconds: 200)),
      );
      expect(
        clock.foregroundSeconds(start.add(const Duration(seconds: 200))),
        storeReviewIdleGap.inSeconds,
      );
    });

    test('does not count without playable notes', () {
      final clock = RecordingVisitClock();
      final start = DateTime(2026, 11, 22, 12, 0, 0);
      clock.noteActivity(notesReady: false, foreground: true, now: start);
      clock.sample(
        notesReady: false,
        foreground: true,
        now: start.add(const Duration(seconds: 200)),
      );
      expect(clock.foregroundSeconds(start.add(const Duration(seconds: 200))), 0);
    });

    test('pauses in the background', () {
      final clock = RecordingVisitClock();
      final start = DateTime(2026, 11, 22, 12, 0, 0);
      clock.noteActivity(notesReady: true, foreground: true, now: start);
      clock.sample(
        notesReady: true,
        foreground: false,
        now: start.add(const Duration(seconds: 30)),
      );
      clock.sample(
        notesReady: true,
        foreground: false,
        now: start.add(const Duration(seconds: 300)),
      );
      expect(clock.foregroundSeconds(start.add(const Duration(seconds: 300))), 30);
    });
  });

  group('visits needed', () {
    test('first show needs one visit, later shows need two', () {
      expect(visitsNeededToArm(showsUsed: 0), 1);
      expect(visitsNeededToArm(showsUsed: 1), 2);
      expect(visitsNeededToArm(showsUsed: 2), 2);
    });
  });
}
