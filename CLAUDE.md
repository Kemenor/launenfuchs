# Launenfuchs — project guide for Claude

Ad-free, no-subscription, **serverless** mood journal (Flutter/Dart, Android-first).
Local-first (drift/SQLite), Riverpod, Material 3, four locales (en/de/fr/it). Model:
`design-concept.md`. Plan & roadmap: `PLAN.md`. Look: `DESIGN_SYSTEM.md` + HTML mockups
in `examples/ui/`. Part of the fox family — shared design system & base stack in
`../fuchsbau`; `../checkfuchs` and `../knabberfuchs` are the siblings to copy
toolchain, CI and release pipeline from.

**Status: planning.** No Flutter project yet — Phase 0 in `PLAN.md` scaffolds it.

## Working in this repo

**Flutter is NOT on PATH — it runs inside a distrobox container named `flutter`.**

```bash
distrobox enter flutter -- bash -lc 'cd ~/Documents/fuchs/launenfuchs && flutter <cmd>'
```

- Analyze / test: `flutter analyze` · `flutter test`. After editing the drift schema:
  `dart run build_runner build --delete-conflicting-outputs`.
- l10n: edit `lib/l10n/app_en.arb`, mirror into `app_de/fr/it.arb`, `flutter gen-l10n`.
  No hardcoded user-facing strings.
- Emulator, adb, release flow, secrets: identical to `../checkfuchs/CLAUDE.md` — copy
  the relevant parts when Phase 0/7 lands.

## Rules specific to this app

- **The stats engine is pure** (`lib/domain/`): no Flutter, no drift, injected `Clock`.
  Committed fixtures are synthetic; the real Daylio backup lives only in the gitignored
  `test/private/` and its golden test must keep matching PLAN.md § Engine. **Never commit
  real mood data, notes or backups.**
- **Absence is not zero** (design-concept §4.3): a day outside every `category_span` of
  a category is *not tracked* — never "none", never "nothing logged".
- **Copy never implies cause or gives advice.** Stats text describes what happened
  together, with `n`. The caveat under *Mood alongside what you logged* is not removable.
- **Saved means saved.** Defaults are written into the entry on save; nothing in the
  engine reads `default_option_id`. Past entries change only through an explicit,
  confirmed bulk action (fill empty days, merge, delete for good, drop on import).
  Removing a category or option always offers **Hide** (data kept) before **Delete for
  good**.
- **No red for mood.** Mood colours come from DESIGN_SYSTEM §1 and always appear with the
  face icon. Red stays destruction-only (Fuchsbau).
- **Mood data is sensitive.** No logging of entries/notes to the console in release, no
  analytics, report exports have notes off by default.
