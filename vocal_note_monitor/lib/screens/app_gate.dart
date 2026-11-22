import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_language.dart';
import '../services/note_spelling.dart';
import '../services/recording_store.dart';
import '../services/store_review_service.dart';
import 'library_screen.dart';
import 'onboarding_screen.dart';

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  var _ready = false;
  var _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final store = context.read<RecordingStore>();
    final spelling = context.read<NoteSpelling>();
    final language = context.read<AppLanguage>();
    final review = context.read<StoreReviewService>();
    final prefs = await SharedPreferences.getInstance();
    await store.load();
    await review.load();
    await spelling.load();
    spelling.followLanguage(language.resolved);
    if (!mounted) return;
    setState(() {
      _showOnboarding = !(prefs.getBool(OnboardingScreen.seenKey) ?? false);
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return OnboardingScreen(onDone: () => setState(() => _showOnboarding = false));
    }
    return const LibraryScreen();
  }
}
