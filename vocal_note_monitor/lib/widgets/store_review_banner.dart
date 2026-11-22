import 'package:flutter/material.dart';

import '../l10n/ui_text.dart';
import '../strategies/store_review_strategy.dart';
import '../theme/musnote_theme.dart';
import '../theme/musnote_tokens.g.dart';

/// Progress strip above the recording list.
class StoreReviewBanner extends StatefulWidget {
  const StoreReviewBanner({
    super.key,
    required this.readyCount,
    required this.onClosing,
    required this.onOpenStore,
    required this.onFinished,
  });

  final int readyCount;
  final VoidCallback onClosing;
  final VoidCallback onOpenStore;
  final void Function(StoreReviewCloseKind kind) onFinished;

  @override
  State<StoreReviewBanner> createState() => _StoreReviewBannerState();
}

class _StoreReviewBannerState extends State<StoreReviewBanner> {
  bool _thanks = false;
  bool _collapsed = false;

  Future<void> _pressCta() async {
    if (_thanks) return;
    widget.onClosing();
    widget.onOpenStore();
    setState(() => _thanks = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _collapsed = true);
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    widget.onFinished(StoreReviewCloseKind.cta);
  }

  Future<void> _pressClose() async {
    if (_collapsed) return;
    widget.onClosing();
    setState(() => _collapsed = true);
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    widget.onFinished(StoreReviewCloseKind.dismiss);
  }

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    final brand = MusnoteTokens.green600;
    final ctaColor = MusnoteTokens.green700;
    final borderColor = MusnoteTokens.green500;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          opacity: _collapsed ? 0 : 1,
          child: _collapsed
              ? const SizedBox(width: double.infinity, height: 0)
              : DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor.withValues(alpha: 0.55)),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 40, 12),
                    child: Stack(
                      children: [
                        if (_thanks)
                          SizedBox(
                            width: double.infinity,
                            height: 76,
                            child: Center(
                              child: Text(
                                text.storeReviewBannerThanks,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: brand,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _BadgeIcon(count: widget.readyCount),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          text.storeReviewBannerTitle(
                                            widget.readyCount,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: MusnoteColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          text.storeReviewBannerSubtitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.35,
                                            color: MusnoteColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: OutlinedButton(
                                  onPressed: _pressCta,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ctaColor,
                                    side: BorderSide(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                    minimumSize: const Size(0, 34),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: Text(
                                    text.storeReviewBannerAction,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        PositionedDirectional(
                          top: 0,
                          end: -28,
                          child: IconButton(
                            tooltip: text.storeReviewBannerClose,
                            onPressed: _pressClose,
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            icon: const Icon(
                              Icons.close,
                              color: MusnoteColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final brand = MusnoteTokens.green600;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: brand.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.piano, color: MusnoteColors.green600),
            ),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: brand,
                shape: BoxShape.circle,
                border: Border.all(color: MusnoteColors.surface2, width: 2),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
