import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';

/// The app lock (design-concept §2.6). Wraps the whole app:
/// - while the app is in the background a plain cover is shown, so the
///   recent-apps preview never reveals the journal;
/// - on a cold start, and on return after the chosen delay, the journal is
///   locked until the phone's own unlock (biometrics or device PIN) succeeds;
/// - it waits for the settings row, so nothing flashes before the lock.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  final _auth = LocalAuthentication();
  bool _locked = true; // until settings say otherwise
  bool _covered = false;
  bool _authenticating = false;
  bool _decided = false;
  DateTime? _leftAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The system's own unlock prompt pauses us — never react to that.
    if (_authenticating) return;
    final s = ref.read(settingsProvider);
    if (!s.appLock) {
      if (_covered) setState(() => _covered = false);
      return;
    }
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _leftAt ??= DateTime.now();
        if (!_covered) setState(() => _covered = true);
      case AppLifecycleState.resumed:
        // Only a departure that happened while the lock was on counts — the
        // prompt that turns the lock on also pauses us, and must not re-lock.
        final left = _leftAt;
        _leftAt = null;
        final relock =
            left != null &&
            DateTime.now().difference(left).inSeconds >= s.appLockDelaySeconds;
        setState(() {
          _covered = false;
          if (relock) _locked = true;
        });
        if (relock) _unlock();
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    _authenticating = true;
    final reason = AppLocalizations.of(context).unlockReason;
    try {
      // The phone's screen lock is gone: the app lock can't do its job, and
      // must never lock someone out of their own journal — it turns itself
      // off instead.
      if (!await _auth.isDeviceSupported()) {
        await ref.read(settingsProvider.notifier).setAppLock(on: false);
        if (mounted) setState(() => _locked = false);
        return;
      }
      final ok = await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
      if (ok && mounted) setState(() => _locked = false);
    } catch (e) {
      debugPrint('unlock failed: $e');
    } finally {
      _authenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    if (!s.loaded) return const _Cover();
    if (!_decided) {
      _decided = true;
      _locked = s.appLock;
      if (_locked) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
      }
    }
    if (!s.appLock) _locked = false;
    if (_locked) return _LockScreen(onUnlock: _unlock);
    return Stack(
      children: [
        widget.child,
        if (_covered) const Positioned.fill(child: _Cover()),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: const SizedBox.expand(),
  );
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.lock_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(l10n.lockedTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Symbols.fingerprint_rounded),
              label: Text(l10n.unlock),
              onPressed: onUnlock,
            ),
          ],
        ),
      ),
    );
  }
}

/// Turning the lock on: only if the phone has a screen lock, and only after
/// one successful unlock (so nobody locks themselves out by accident).
Future<bool> confirmAppLock(BuildContext context) async {
  final auth = LocalAuthentication();
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    if (!await auth.isDeviceSupported()) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.appLockUnavailable)));
      return false;
    }
    return await auth.authenticate(localizedReason: l10n.unlockReason);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.appLockUnavailable)));
    return false;
  }
}
