import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/country_language.dart';
import '../l10n/ui_text.dart';
import '../services/app_language.dart';
import '../services/note_spelling.dart';
import '../theme/musnote_theme.dart';

String endonym(AppLocalizations text, String code) {
  return switch (code) {
    'ru' => text.langRu,
    'es' => text.langEs,
    'de' => text.langDe,
    'fr' => text.langFr,
    'it' => text.langIt,
    'pl' => text.langPl,
    _ => text.langEn,
  };
}

String languageValue(AppLocalizations text, AppLanguage language) {
  if (language.choice == AppLanguage.automatic) {
    return text.languageAutoNamed(endonym(text, language.resolved));
  }
  return endonym(text, language.choice);
}

Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: MusnoteColors.surface,
    constraints: const BoxConstraints(maxWidth: 480),
    builder: (context) => const LanguagePickerSheet(),
  );
}

class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    final language = context.watch<AppLanguage>();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageRow(
            label: text.languageAutoNamed(endonym(text, language.systemLanguage)),
            selected: language.choice == AppLanguage.automatic,
            onTap: () => _pick(context, AppLanguage.automatic),
          ),
          for (final code in appLanguages)
            _LanguageRow(
              label: endonym(text, code),
              selected: language.choice == code,
              onTap: () => _pick(context, code),
            ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, String value) async {
    final language = context.read<AppLanguage>();
    final spelling = context.read<NoteSpelling>();
    await language.setChoice(value);
    spelling.followLanguage(language.resolved);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check, color: MusnoteColors.green700)
          : null,
      onTap: onTap,
    );
  }
}

class LanguageChip extends StatelessWidget {
  const LanguageChip({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguage>();
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: MusnoteColors.muted,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => showLanguagePicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, size: 16),
          const SizedBox(width: 4),
          Text(endonym(t(context), language.resolved)),
          const Icon(Icons.expand_more, size: 16),
        ],
      ),
    );
  }
}
