/// System dialogs the app opens itself — the notification permission, the
/// file picker, the save dialog, the unlock prompt — pause the app just like
/// leaving it does. Run them through [systemPrompt] so the app lock knows the
/// pause is ours and doesn't lock the journal on the way back.
Future<T> systemPrompt<T>(Future<T> Function() prompt) async {
  _open++;
  try {
    return await prompt();
  } finally {
    _open--;
  }
}

/// Whether one of our own system dialogs is open right now.
bool get systemPromptOpen => _open > 0;

int _open = 0;
