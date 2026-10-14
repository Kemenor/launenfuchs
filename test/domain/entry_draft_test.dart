import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/entry_draft.dart';
import 'package:launenfuchs/domain/mood.dart';

import '../support/fixtures.dart';

void main() {
  const today = Day(2026, 10, 14);

  test('a new entry starts with defaults pending — and they are saved', () {
    final d = EntryDraft.forDay(journalOf([]), today);
    expect(d.isNew, isTrue);
    expect(d.isPending(work), isTrue);
    expect(d.isSelected(work, 13), isTrue);
    expect(d.optionIds, {13}, reason: 'saved means saved');
    expect(d.isPending(health), isFalse);
  });

  test('one per day: a tap replaces, a second tap clears', () {
    final d = EntryDraft.forDay(journalOf([]), today);
    d.tap(work, 11);
    expect(d.isPending(work), isFalse);
    expect(d.selectedIn(work), {11});
    d.tap(work, 12);
    expect(d.selectedIn(work), {12});
    d.tap(work, 12);
    expect(d.selectedIn(work), isEmpty);
  });

  test('tapping the pending default clears the category', () {
    final d = EntryDraft.forDay(journalOf([]), today);
    d.tap(work, 13);
    expect(d.selectedIn(work), isEmpty);
    expect(d.isPending(work), isFalse);
  });

  test('any number: taps toggle independently', () {
    final d = EntryDraft.forDay(journalOf([]), today);
    d.tap(health, 21);
    d.tap(health, 22);
    expect(d.selectedIn(health), {21, 22});
    d.tap(health, 21);
    expect(d.selectedIn(health), {22});
  });

  test('slider: setOne always sets, clear empties', () {
    final d = EntryDraft.forDay(journalOf([]), today);
    d.setOne(coffee, 32);
    d.setOne(coffee, 32);
    expect(d.selectedIn(coffee), {32});
    d.clear(coffee);
    expect(d.selectedIn(coffee), isEmpty);
  });

  test('an existing entry loads as stored — no defaults re-applied', () {
    final j = journalOf([
      entry(today, Mood.good, {11, 21}, '  a note '),
      entry(today.addDays(-1), Mood.meh),
    ]);
    final d = EntryDraft.forDay(j, today);
    expect(d.isNew, isFalse);
    expect(d.mood, Mood.good);
    expect(d.selectedIn(work), {11});
    expect(d.isPending(work), isFalse);
    expect(d.noteOrNull, 'a note');

    final y = EntryDraft.forDay(j, today.addDays(-1));
    expect(y.selectedIn(work), isEmpty, reason: 'stored as nothing logged');
  });

  test('saving needs a mood', () {
    final d = EntryDraft.forDay(journalOf([]), today);
    expect(d.canSave, isFalse);
    d.mood = Mood.bad;
    expect(d.canSave, isTrue);
  });
}
