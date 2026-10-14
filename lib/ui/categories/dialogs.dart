import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';
import '../option_icons.dart';

/// Name + icon, for a new or renamed category / option.
Future<(String, String)?> showNameIconDialog(
  BuildContext context, {
  required String title,
  String name = '',
  String icon = 'label',
}) => showDialog<(String, String)>(
  context: context,
  builder: (_) => _NameIconDialog(title: title, name: name, icon: icon),
);

class _NameIconDialog extends StatefulWidget {
  const _NameIconDialog({
    required this.title,
    required this.name,
    required this.icon,
  });
  final String title, name, icon;

  @override
  State<_NameIconDialog> createState() => _NameIconDialogState();
}

class _NameIconDialogState extends State<_NameIconDialog> {
  late final _name = TextEditingController(text: widget.name);
  late String _icon = widget.icon;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.nameRequired,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Text(l10n.iconTitle, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            SizedBox(
              height: 220,
              child: GridView.count(
                crossAxisCount: 6,
                children: [
                  for (final MapEntry(key: slug, value: icon)
                      in optionIcons.entries)
                    IconButton(
                      isSelected: slug == _icon,
                      style: IconButton.styleFrom(
                        backgroundColor: slug == _icon
                            ? scheme.primary.withValues(alpha: 0.15)
                            : null,
                      ),
                      icon: Icon(
                        icon,
                        color: slug == _icon ? scheme.primary : null,
                      ),
                      onPressed: () => setState(() => _icon = slug),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _name.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, (_name.text.trim(), _icon)),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

enum RemoveChoice { hide, delete }

/// The remove dialog (DESIGN_SYSTEM §2.4): two stacked choices, not a yes/no.
/// Hide first (the safe path); Delete for good is red and asks once more.
Future<RemoveChoice?> showRemoveDialog(
  BuildContext context, {
  required String name,
  required int dayCount,
  required bool isCategory,
}) async {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final choice = await showModalBottomSheet<RemoveChoice>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.removeTitle(name), style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.removeLoggedOn(dayCount),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _Choice(
              icon: Symbols.visibility_off_rounded,
              title: l10n.hideChoice,
              body: isCategory ? l10n.hideCategoryBody : l10n.hideOptionBody,
              filled: true,
              onTap: () => Navigator.pop(c, RemoveChoice.hide),
            ),
            const SizedBox(height: 8),
            _Choice(
              icon: Symbols.delete_rounded,
              title: l10n.deleteForGood,
              body: l10n.deleteForGoodBody,
              danger: true,
              onTap: () => Navigator.pop(c, RemoveChoice.delete),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    ),
  );
  if (choice != RemoveChoice.delete || !context.mounted) return choice;
  final sure = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l10n.deleteForGoodConfirm(name)),
      content: Text(l10n.removeLoggedOn(dayCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.pop(c, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return sure == true ? RemoveChoice.delete : null;
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.filled = false,
    this.danger = false,
  });

  final IconData icon;
  final String title, body;
  final VoidCallback onTap;
  final bool filled, danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = filled
        ? scheme.onPrimary
        : (danger ? scheme.error : scheme.onSurface);
    return Material(
      color: filled ? scheme.primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: filled
            ? BorderSide.none
            : BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: TextStyle(
                        color: fg.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
