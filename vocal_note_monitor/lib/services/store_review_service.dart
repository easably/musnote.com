import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../strategies/store_review_strategy.dart';

/// Persists arming and show history for the library rating strip.
class StoreReviewService extends ChangeNotifier {
  StoreReviewService();

  static const _kShowsUsed = 'store_review_shows_used';
  static const _kRated = 'store_review_rated';
  static const _kVisitsSinceShow = 'store_review_visits_since_show';
  static const _kArmedId = 'store_review_armed_id';
  static const _kLifetimeReady = 'store_review_lifetime_ready';

  SharedPreferences? _prefs;
  final RecordingVisitClock _clock = RecordingVisitClock();

  String? _activeRecordingId;
  bool _foreground = true;
  bool _closing = false;

  int showsUsed = 0;
  bool alreadyRated = false;
  int visitsSinceLastShow = 0;
  String? armedRecordingId;
  int lifetimeReadyCount = 0;

  bool get closing => _closing;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    showsUsed = _prefs?.getInt(_kShowsUsed) ?? 0;
    alreadyRated = _prefs?.getBool(_kRated) ?? false;
    visitsSinceLastShow = _prefs?.getInt(_kVisitsSinceShow) ?? 0;
    armedRecordingId = _prefs?.getString(_kArmedId);
    if (armedRecordingId != null && armedRecordingId!.isEmpty) {
      armedRecordingId = null;
    }
    lifetimeReadyCount = _prefs?.getInt(_kLifetimeReady) ?? 0;
    notifyListeners();
  }

  /// Count a recording that just got playable notes for the first time.
  Future<void> noteReadySuccess() async {
    lifetimeReadyCount += 1;
    await _prefs?.setInt(_kLifetimeReady, lifetimeReadyCount);
    notifyListeners();
  }

  void enterRecording(String recordingId) {
    if (_activeRecordingId == recordingId) return;
    if (_activeRecordingId != null) {
      // Different recording without a clean leave — drop the unfinished clock.
      _clock.reset();
    }
    _activeRecordingId = recordingId;
    _clock.reset();
    _foreground = true;
  }

  void noteActivity({required bool notesReady, DateTime? now}) {
    if (_activeRecordingId == null) return;
    _clock.noteActivity(
      notesReady: notesReady,
      foreground: _foreground,
      now: now ?? DateTime.now(),
    );
  }

  void setForeground(bool foreground, {required bool notesReady, DateTime? now}) {
    if (_activeRecordingId == null) return;
    final moment = now ?? DateTime.now();
    _clock.sample(
      notesReady: notesReady,
      foreground: _foreground,
      now: moment,
    );
    _foreground = foreground;
    if (foreground) {
      _clock.noteActivity(
        notesReady: notesReady,
        foreground: true,
        now: moment,
      );
    }
  }

  /// Finish the open visit. Arms the strip when the rules say so.
  Future<void> leaveRecording({
    required bool notesReady,
    DateTime? now,
  }) async {
    if (_activeRecordingId == null) return;
    final id = _activeRecordingId!;
    final moment = now ?? DateTime.now();
    _clock.sample(
      notesReady: notesReady,
      foreground: _foreground,
      now: moment,
    );
    final seconds = _clock.foregroundSeconds(moment);
    _activeRecordingId = null;
    _clock.reset();
    _foreground = true;

    final qualifies = visitQualifiesForStoreReview(
      notesReady: notesReady,
      foregroundSeconds: seconds,
    );
    if (!qualifies) {
      notifyListeners();
      return;
    }

    visitsSinceLastShow += 1;
    await _prefs?.setInt(_kVisitsSinceShow, visitsSinceLastShow);

    final arm = shouldArmStoreReviewBanner(
      notesReady: notesReady,
      foregroundSeconds: seconds,
      showsUsed: showsUsed,
      alreadyRated: alreadyRated,
      alreadyArmed: armedRecordingId != null,
      visitsSinceLastShow: visitsSinceLastShow,
    );
    if (arm) {
      armedRecordingId = id;
      await _prefs?.setString(_kArmedId, id);
    }
    notifyListeners();
  }

  bool isEligibleToShow({required bool recordingStillReady}) {
    return shouldShowStoreReviewBanner(
      armed: armedRecordingId != null,
      recordingStillReady: recordingStillReady,
      showsUsed: showsUsed,
      alreadyRated: alreadyRated,
      sessionShown: StoreReviewSessionGate.shown,
    );
  }

  void markSessionShown() {
    StoreReviewSessionGate.markShown();
  }

  void setClosing(bool value) {
    if (_closing == value) return;
    _closing = value;
    notifyListeners();
  }

  /// Record that the strip left. CTA marks rated immediately.
  Future<void> consume(StoreReviewCloseKind kind) async {
    if (armedRecordingId == null && kind != StoreReviewCloseKind.cta) {
      _closing = false;
      notifyListeners();
      return;
    }

    if (kind == StoreReviewCloseKind.cta) {
      alreadyRated = true;
      showsUsed = storeReviewMaxShows;
      await _prefs?.setBool(_kRated, true);
      await _prefs?.setInt(_kShowsUsed, showsUsed);
    } else {
      showsUsed = (showsUsed + 1).clamp(0, storeReviewMaxShows);
      await _prefs?.setInt(_kShowsUsed, showsUsed);
    }

    armedRecordingId = null;
    visitsSinceLastShow = 0;
    _closing = false;
    await _prefs?.remove(_kArmedId);
    await _prefs?.setInt(_kVisitsSinceShow, 0);
    notifyListeners();
  }

  /// Drop the arm when the recording is gone or no longer ready.
  Future<void> clearArmIfInvalid({required bool recordingStillReady}) async {
    if (armedRecordingId == null) return;
    if (recordingStillReady) return;
    armedRecordingId = null;
    await _prefs?.remove(_kArmedId);
    notifyListeners();
  }
}
