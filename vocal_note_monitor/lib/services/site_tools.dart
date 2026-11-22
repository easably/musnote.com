/// Pages that exist on musnote.com. Russian and German have piano and chords.
const localizedSitePaths = {
  '/piano',
  '/chords/chart/',
  '/chords/clock/',
  '/chords/hops/',
  '/chords/patterns/',
};

String sitePathFor(String language, String path) {
  if ((language == 'ru' || language == 'de') && localizedSitePaths.contains(path)) {
    return '/$language$path';
  }
  return path;
}

Uri siteToolUri(String language, String path) {
  final localized = sitePathFor(language, path);
  return Uri.https('musnote.com', localized, const {'app': '1'});
}

bool isMusnoteHost(String host) {
  final name = host.toLowerCase();
  return name == 'musnote.com' || name == 'www.musnote.com';
}

/// Stay inside the site. The app list and anything off musnote.com open outside.
bool siteToolStaysInside(Uri uri) {
  if (!isMusnoteHost(uri.host)) return false;
  final path = uri.path;
  if (path == '/app' || path.startsWith('/app/')) return false;
  return true;
}
