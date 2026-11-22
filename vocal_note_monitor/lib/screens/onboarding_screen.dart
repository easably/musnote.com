import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../l10n/ui_text.dart';
import '../theme/musnote_theme.dart';
import '../widgets/language_picker_sheet.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  static const seenKey = 'onboarding_shown';
  static const pageCount = 4;

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _page = PageController();
  late final AnimationController _motion;
  var _index = 0;
  var _closing = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    _page.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_closing) return;
    _closing = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.seenKey, true);
    if (!mounted) return;
    widget.onDone();
  }

  void _next() {
    if (_index >= OnboardingScreen.pageCount - 1) {
      _finish();
      return;
    }
    _page.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MusnoteColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          final pages = _pages(context, wide: wide);
          final body = Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _page,
                  onPageChanged: (index) => setState(() => _index = index),
                  children: pages,
                ),
              ),
              _footer(context, wide: wide),
            ],
          );
          final framed = wide
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: body,
                )
              : MusnotePage(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: body,
                  ),
                );
          return SafeArea(child: _withLanguage(context, framed));
        },
      ),
    );
  }

  Widget _withLanguage(BuildContext context, Widget child) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 0,
          left: 0,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: MusnoteColors.muted,
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            onPressed: _finish,
            child: Text(t(context).onbSkip),
          ),
        ),
        const Positioned(top: 0, right: 0, child: LanguageChip()),
      ],
    );
  }

  Widget _footer(BuildContext context, {required bool wide}) {
    final last = _index == OnboardingScreen.pageCount - 1;
    final button = FilledButton(
      style: wide
          ? FilledButton.styleFrom(
              minimumSize: const Size(420, 56),
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            )
          : null,
      onPressed: _next,
      child: Text(last ? t(context).start : t(context).onbNext),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _dots(),
          const SizedBox(height: 14),
          wide ? button : SizedBox(width: double.infinity, child: button),
        ],
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < OnboardingScreen.pageCount; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _index ? MusnoteColors.green500 : const Color(0xFFD4DDD9),
              borderRadius: BorderRadius.circular(9),
            ),
          ),
      ],
    );
  }

  List<Widget> _pages(BuildContext context, {required bool wide}) {
    final text = t(context);
    final titleSize = wide ? 40.0 : null;
    return [
      _pageBody(
        wide: wide,
        titleSize: titleSize,
        visual: _art(wide, Lottie.asset('assets/lottie/musnote-loading.json', fit: BoxFit.contain)),
        title: text.onbTitle,
        extra: Text(
          text.onbLine,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: wide ? 17 : null),
        ),
        body: text.onbBody,
      ),
      _pageBody(
        wide: wide,
        titleSize: titleSize,
        visual: _art(
          wide,
          AnimatedBuilder(
            animation: _motion,
            builder: (context, _) => CustomPaint(
              painter: _WavePainter(_motion.value * math.pi * 2),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        title: text.onbSoundTitle,
        body: text.onbSoundBody,
      ),
      _pageBody(
        wide: wide,
        titleSize: titleSize,
        visual: _art(
          wide,
          Stack(
            alignment: Alignment.center,
            children: [
              Lottie.asset('assets/lottie/musnote-loading.json', fit: BoxFit.contain),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _chips(text),
                ),
              ),
            ],
          ),
        ),
        title: text.onbTracksTitle,
        body: text.onbTracksBody,
      ),
      _pageBody(
        wide: wide,
        titleSize: titleSize,
        visual: _art(
          wide,
          AnimatedBuilder(
            animation: _motion,
            builder: (context, _) => CustomPaint(
              painter: _FallPainter(_motion.value),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        title: text.onbPlayTitle,
        body: text.onbPlayBody,
      ),
    ];
  }

  Widget _art(bool wide, Widget child) {
    return Container(
      width: wide ? 680 : double.infinity,
      height: wide ? 272 : 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MusnoteColors.surface2,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _chips(AppLocalizations text) {
    final names = [text.stemVocals, text.stemPiano, text.stemBass, text.stemOther];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final name in names)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: MusnoteColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: MusnoteColors.line),
            ),
            child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _pageBody({
    required bool wide,
    required double? titleSize,
    required Widget visual,
    required String title,
    Widget? extra,
    required String body,
  }) {
    final titleStyle = titleSize == null
        ? MusnoteType.display
        : MusnoteType.display.copyWith(fontSize: titleSize);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        visual,
        const SizedBox(height: 24),
        Text(title, textAlign: TextAlign.center, style: titleStyle),
        if (extra != null) ...[const SizedBox(height: 12), extra],
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: wide ? 17 : null, color: MusnoteColors.muted),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [MusnoteColors.green500, Color(0xFFA8E9D0), Color(0xFFD5F5E9)];
    for (var k = 0; k < colors.length; k++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = k == 0 ? 4 : 2
        ..strokeCap = StrokeCap.round
        ..color = colors[k];
      final path = Path();
      for (var x = 0.0; x <= size.width; x += 4) {
        final u = size.width == 0 ? 0.0 : x / size.width;
        final env = math.sin(math.pi * u);
        final y = size.height / 2 -
            env * (size.height * 0.22 - k * 10) * math.sin(u * 14 - phase * (1.4 + k * 0.2) + k);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.phase != phase;
}

class _FallPainter extends CustomPainter {
  _FallPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const whites = 12;
    final keyW = size.width / whites;
    final keyH = size.height * 0.34;
    final keyTop = size.height - keyH;
    final keyPaint = Paint()..color = Colors.white;
    final line = Paint()
      ..color = MusnoteColors.keyLine
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < whites; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * keyW + 1, keyTop, keyW - 2, keyH - 4),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, keyPaint);
      canvas.drawRRect(rect, line);
    }
    final note = Paint()..color = MusnoteColors.green500;
    const lanes = [2, 5, 7, 9];
    for (var i = 0; i < lanes.length; i++) {
      final travel = (t + i * 0.23) % 1;
      final y = keyTop - 18 - (1 - travel) * (keyTop - 24);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lanes[i] * keyW + 4, y, keyW - 10, 14),
          const Radius.circular(4),
        ),
        note,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FallPainter oldDelegate) => oldDelegate.t != t;
}
