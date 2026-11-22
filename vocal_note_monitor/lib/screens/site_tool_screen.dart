import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../l10n/ui_text.dart';
import '../services/pitch_service.dart';
import '../services/site_tools.dart';
import '../theme/musnote_theme.dart';

/// One site tool, full screen, with a close button on the left.
class SiteToolScreen extends StatefulWidget {
  const SiteToolScreen({super.key, required this.title, required this.path});

  final String title;
  final String path;

  @override
  State<SiteToolScreen> createState() => _SiteToolScreenState();
}

class _SiteToolScreenState extends State<SiteToolScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _failed = false;
  @override
  void initState() {
    super.initState();
    final params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true)
        : const PlatformWebViewControllerCreationParams();
    _controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: _onPermission,
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            if (mounted) {
              setState(() {
                _failed = true;
                _loading = false;
              });
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null || siteToolStaysInside(uri)) {
              return NavigationDecision.navigate;
            }
            launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
        ),
      );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PitchService>().stop();
      _load();
    });
  }

  Future<void> _onPermission(WebViewPermissionRequest request) async {
    final pitch = context.read<PitchService>();
    final onlyMic = request.types.length == 1 &&
        request.types.contains(WebViewPermissionResourceType.microphone);
    final current = await _controller.currentUrl();
    final host = current == null ? '' : (Uri.tryParse(current)?.host ?? '');
    final onSite = isMusnoteHost(host);
    if (!onlyMic || !onSite) {
      await request.deny();
      return;
    }
    await pitch.stop();
    final allowed = await AudioRecorder().hasPermission();
    if (!allowed) {
      await request.deny();
      return;
    }
    await request.grant();
  }

  void _load() {
    final language = Localizations.localeOf(context).languageCode;
    setState(() {
      _failed = false;
      _loading = true;
    });
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    _controller.loadRequest(siteToolUri(language, widget.path));
  }

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    return Scaffold(
      backgroundColor: MusnoteColors.surface,
      appBar: AppBar(
        backgroundColor: MusnoteColors.surface,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: text.cancel,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Stack(
        children: [
          if (!_failed) WebViewWidget(controller: _controller),
          if (_loading && !_failed) const LinearProgressIndicator(minHeight: 2),
          if (_failed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(text.toolOffline, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _load, child: Text(text.toolRetry)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
