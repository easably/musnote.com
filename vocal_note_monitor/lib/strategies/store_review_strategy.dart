/// When the quiet store-rating strip may appear above the recording library.
///
/// Armed only after playable notes and a real visit on that recording.
/// Denser than Summify: first qualifying visit can arm; after a show without
/// a store tap, two more visits are enough. No calendar cooldown.
library;

/// Lifetime shows of the progress strip.
const int storeReviewMaxShows = 3;

/// Foreground seconds on a ready recording that count as using it.
const int storeReviewPassiveSeconds = 120;

/// No pointer, scroll, or playback for this long: the clock stops.
const Duration storeReviewIdleGap = Duration(seconds: 60);

/// Qualifying visits needed to arm before any show.
const int storeReviewVisitsBeforeFirstShow = 1;

/// Qualifying visits needed after a show that was closed without the CTA.
const int storeReviewVisitsBetweenShows = 2;

/// How the strip left the screen.
enum StoreReviewCloseKind { dismiss, cta, leave }

/// Lives only for this app launch. Not written to disk.
class StoreReviewSessionGate {
  static bool shown = false;

  static void markShown() => shown = true;

  /// Tests only.
  static void reset() {
    shown = false;
  }
}

/// Seconds on a ready recording while the screen is in the foreground
/// and the person is not idle.
class RecordingVisitClock {
  int accumulatedMs = 0;
  DateTime? _segmentStart;
  DateTime? _lastActivity;

  /// A touch, scroll, or playback tick. Closes an idle gap before the new
  /// moment starts.
  void noteActivity({
    required bool notesReady,
    required bool foreground,
    required DateTime now,
  }) {
    if (_lastActivity != null) {
      onSample(
        notesReady: notesReady,
        foreground: foreground,
        now: now,
        lastActivity: _lastActivity!,
      );
    }
    _lastActivity = now;
    onSample(
      notesReady: notesReady,
      foreground: foreground,
      now: now,
      lastActivity: now,
    );
  }

  /// Sample without moving the last touch. Used when the app pauses or closes.
  void sample({
    required bool notesReady,
    required bool foreground,
    required DateTime now,
  }) {
    onSample(
      notesReady: notesReady,
      foreground: foreground,
      now: now,
      lastActivity: _lastActivity ?? now,
    );
  }

  void onSample({
    required bool notesReady,
    required bool foreground,
    required DateTime now,
    required DateTime lastActivity,
  }) {
    final idleAt = lastActivity.add(storeReviewIdleGap);
    final running = notesReady && foreground && now.isBefore(idleAt);
    if (running) {
      _segmentStart ??= now;
      return;
    }
    if (_segmentStart == null) return;
    final end = now.isBefore(idleAt) ? now : idleAt;
    if (end.isAfter(_segmentStart!)) {
      accumulatedMs += end.difference(_segmentStart!).inMilliseconds;
    }
    _segmentStart = null;
  }

  int foregroundSeconds(DateTime now) {
    var ms = accumulatedMs;
    if (_segmentStart != null) {
      final delta = now.difference(_segmentStart!).inMilliseconds;
      if (delta > 0) ms += delta;
    }
    if (ms < 0) return 0;
    return ms ~/ 1000;
  }

  void reset() {
    accumulatedMs = 0;
    _segmentStart = null;
    _lastActivity = null;
  }
}

/// This visit would count, ignoring how many shows are left.
bool visitQualifiesForStoreReview({
  required bool notesReady,
  required int foregroundSeconds,
}) {
  if (!notesReady) return false;
  return foregroundSeconds >= storeReviewPassiveSeconds;
}

int visitsNeededToArm({required int showsUsed}) {
  if (showsUsed <= 0) return storeReviewVisitsBeforeFirstShow;
  return storeReviewVisitsBetweenShows;
}

/// Arm a pending strip. Show rules are checked later on the library.
bool shouldArmStoreReviewBanner({
  required bool notesReady,
  required int foregroundSeconds,
  required int showsUsed,
  required bool alreadyRated,
  required bool alreadyArmed,
  required int visitsSinceLastShow,
}) {
  if (alreadyArmed || alreadyRated) return false;
  if (showsUsed >= storeReviewMaxShows) return false;
  if (!visitQualifiesForStoreReview(
    notesReady: notesReady,
    foregroundSeconds: foregroundSeconds,
  )) {
    return false;
  }
  return visitsSinceLastShow >= visitsNeededToArm(showsUsed: showsUsed);
}

/// Whether the strip is on screen. Session gate is checked by the list.
bool shouldShowStoreReviewBanner({
  required bool armed,
  required bool recordingStillReady,
  required int showsUsed,
  required bool alreadyRated,
  required bool sessionShown,
}) {
  if (!armed || !recordingStillReady || alreadyRated) return false;
  if (showsUsed >= storeReviewMaxShows) return false;
  if (sessionShown) return false;
  return true;
}

/// The strip stays up while it is closing, so the thanks line can finish
/// after the show has already been recorded.
bool keepStoreReviewBannerMounted({
  required bool eligible,
  required bool closing,
}) =>
    eligible || closing;
