import 'category.dart';
import 'day.dart';
import 'journal.dart';
import 'mood.dart';

/// The entry sheet's working state (design-concept §3), kept pure so the
/// selection rules are unit-tested rather than buried in widgets:
///
/// - *one per day* categories replace; tapping the selected option clears it;
/// - *any number* categories toggle;
/// - on a **new** entry, a category's default starts selected but *pending*
///   (shown neutral with a DEFAULT tag). Pending or not, it is saved — the
///   draft's [optionIds] include it. Any touch of the category ends pending.
class EntryDraft {
  EntryDraft._({
    required this.day,
    required this.isNew,
    this.mood,
    this.note = '',
    Map<int, Set<int>>? selection,
    Set<int>? pending,
  }) : _selection = selection ?? {},
       _pending = pending ?? {};

  /// A draft for [day]: the stored entry, or a new one with defaults pending.
  factory EntryDraft.forDay(Journal journal, Day day) {
    final existing = journal.entryOn(day);
    if (existing != null) {
      final selection = <int, Set<int>>{};
      for (final id in existing.optionIds) {
        final c = journal.categoryOfOption(id);
        if (c != null) (selection[c.id] ??= {}).add(id);
      }
      return EntryDraft._(
        day: day,
        isNew: false,
        mood: existing.mood,
        note: existing.note ?? '',
        selection: selection,
      );
    }
    final selection = <int, Set<int>>{};
    final pending = <int>{};
    for (final c in journal.visibleCategories) {
      final d = c.defaultOption;
      if (c.mode == CategoryMode.one && d != null) {
        selection[c.id] = {d.id};
        pending.add(c.id);
      }
    }
    return EntryDraft._(
      day: day,
      isNew: true,
      selection: selection,
      pending: pending,
    );
  }

  final Day day;

  /// No stored entry yet for [day].
  final bool isNew;
  Mood? mood;
  String note;

  final Map<int, Set<int>> _selection;
  final Set<int> _pending;

  Set<int> selectedIn(Category c) => Set.unmodifiable(_selection[c.id] ?? {});
  bool isSelected(Category c, int optionId) =>
      _selection[c.id]?.contains(optionId) ?? false;

  /// The category still shows its untouched default (neutral + DEFAULT tag).
  bool isPending(Category c) => _pending.contains(c.id);

  /// A chip tap.
  void tap(Category c, int optionId) {
    _pending.remove(c.id);
    final current = _selection[c.id] ?? <int>{};
    final on = current.contains(optionId);
    if (c.mode == CategoryMode.one) {
      _selection[c.id] = on ? {} : {optionId};
    } else {
      _selection[c.id] = on
          ? ({...current}..remove(optionId))
          : {...current, optionId};
    }
  }

  /// A slider move: always sets (never toggles).
  void setOne(Category c, int optionId) {
    _pending.remove(c.id);
    _selection[c.id] = {optionId};
  }

  /// The slider's ×: nothing logged for this category.
  void clear(Category c) {
    _pending.remove(c.id);
    _selection[c.id] = {};
  }

  /// What gets saved — pending defaults included ("saved means saved").
  Set<int> get optionIds => {for (final s in _selection.values) ...s};

  bool get canSave => mood != null;

  /// The note to store: trimmed, empty → null.
  String? get noteOrNull {
    final t = note.trim();
    return t.isEmpty ? null : t;
  }
}
