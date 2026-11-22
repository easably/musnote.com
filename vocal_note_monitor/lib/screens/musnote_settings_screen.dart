import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/ui_text.dart';
import '../services/app_language.dart';
import '../services/note_spelling.dart';
import '../theme/musnote_theme.dart';
import '../widgets/language_picker_sheet.dart';
import 'onboarding_screen.dart';

class MusnoteSettingsScreen extends StatelessWidget {
  const MusnoteSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    final spelling = context.watch<NoteSpelling>();
    final language = context.watch<AppLanguage>();
    return Scaffold(
      backgroundColor: MusnoteColors.surface2,
      appBar: AppBar(
        backgroundColor: MusnoteColors.surface,
        title: Text(text.settings),
      ),
      body: MusnotePage(
        child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Text(text.language.toUpperCase(), style: MusnoteType.section),
          ),
          ListTile(
            title: Text(text.language),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      languageValue(text, language),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: MusnoteColors.muted),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: MusnoteColors.muted),
                ],
              ),
            ),
            onTap: () => showLanguagePicker(context),
          ),
          SwitchListTile(
            title: Text(text.noteNames),
            subtitle: Text(spelling.solfegeOn ? text.noteSolfege : text.noteLetters),
            value: spelling.solfegeOn,
            onChanged: spelling.setSolfege,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Text(text.about.toUpperCase(), style: MusnoteType.section),
          ),
          ListTile(
            title: Text(text.howItWorks),
            trailing: const Icon(Icons.chevron_right, color: MusnoteColors.muted),
            onTap: () => _openIntro(context),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '…';
              return ListTile(
                title: Text(text.version),
                trailing: Text(version),
              );
            },
          ),
          ListTile(
            title: Text(text.privacy),
            onTap: () => launchUrl(
              Uri.parse('https://musnote.com/privacy/'),
              mode: LaunchMode.inAppBrowserView,
            ),
          ),
          ListTile(
            title: Text(text.writeUs),
            subtitle: const Text('support@englishingames.com'),
            onTap: () => launchUrl(
              Uri.parse('mailto:support@englishingames.com'),
            ),
          ),
        ],
      ),
      ),
    );
  }

}

void _openIntro(BuildContext context) {
  var closed = false;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (routeContext) => OnboardingScreen(
        onDone: () {
          if (closed || !routeContext.mounted) return;
          closed = true;
          Navigator.of(routeContext).pop();
        },
      ),
    ),
  );
}
