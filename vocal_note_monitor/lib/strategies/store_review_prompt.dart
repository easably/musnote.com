import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// App Store numeric id when the listing exists. Empty until ASC assigns one.
const String storeReviewIosAppId = '';

/// Page of this app in the store. No in-app star sheet.
Future<void> openAppStoreListing() async {
  final uri = storeReviewListingUri();
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Uri? storeReviewListingUri() {
  if (kIsWeb) return null;
  if (Platform.isIOS) {
    if (storeReviewIosAppId.isEmpty) return null;
    return Uri.parse('https://apps.apple.com/app/id$storeReviewIosAppId');
  }
  if (Platform.isAndroid) {
    return Uri.parse(
      'https://play.google.com/store/apps/details?id=com.musnote.vocalNoteMonitor',
    );
  }
  return null;
}
