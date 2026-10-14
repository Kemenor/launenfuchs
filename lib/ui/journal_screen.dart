import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import 'empty_state.dart';

/// The Journal tab — month calendar + entries (DESIGN_SYSTEM §2.1). Phase 0:
/// the empty journal.
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navJournal)),
      body: EmptyState(
        icon: Symbols.sentiment_satisfied_rounded,
        title: l10n.journalEmptyTitle,
        body: l10n.journalEmptyBody,
      ),
    );
  }
}
