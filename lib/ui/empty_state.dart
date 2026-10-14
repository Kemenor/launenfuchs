import 'package:flutter/material.dart';

/// A calm, centred empty state: icon, optional headline, body in muted ink.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    this.title,
    required this.body,
  });

  final IconData icon;
  final String? title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
