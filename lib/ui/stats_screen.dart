import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import 'empty_state.dart';

/// The Stats tab — customizable tiles (DESIGN_SYSTEM §2.3). Phase 0: the
/// empty state.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navStats)),
      body: EmptyState(
        icon: Symbols.insights_rounded,
        body: l10n.statsEmptyBody,
      ),
    );
  }
}
