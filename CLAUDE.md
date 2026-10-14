# Launenfuchs — project guide for Claude

Ad-free, no-subscription, **serverless** mood journal (Flutter/Dart, Android-first).
Local-first (drift/SQLite), Riverpod, Material 3, four locales (en/de/fr/it). Model:
`design-concept.md`. Plan & roadmap: `PLAN.md`. Look: `DESIGN_SYSTEM.md` + HTML mockups
in `examples/ui/`. Part of the fox family — shared design system & base stack in
`../fuchsbau`; `../checkfuchs` and `../knabberfuchs` are the siblings to copy
toolchain, CI and release pipeline from.

**Status: v1.0.0 feature-complete** (Phases 0–6 + release tooling, 74 tests). Not yet
published — see PLAN.md § Release for what needs Thomas (keystore, store records).

## Working in this repo

**Flutter is NOT on PATH — it runs inside a distrobox container named `flutter`**
(Flutter pinned in `.fvmrc`, same as the siblings; CI reads it):

```bash
distrobox enter flutter -- bash -lc 'export PATH=$HOME/development/flutter/bin:$PATH; cd ~/Documents/fuchs/launenfuchs && flutter <cmd>'
```

- **Analyze / test:** `flutter analyze` · `flutter test`. CI (`ci.yml`) also enforces
  `dart format` and fresh drift codegen — after editing `lib/data/db/database.dart` run
  `dart run build_runner build --delete-conflicting-outputs` and commit
  `database.g.dart`. (The options table is `CategoryOptions`: `Options` would shadow
  drift's `GeneratedDatabase.options`.)
- **l10n:** edit `lib/l10n/app_en.arb` (template, with `@key` descriptions), mirror the
  key into `app_de/fr/it.arb`, run `flutter gen-l10n`. The generated
  `app_localizations*.dart` are gitignored. No hardcoded user-facing strings.
- **Phone** (A024, Android 16, `adb` on the host): build with
  `flutter build apk --debug --target-platform android-arm64`, then
  `adb -s 00022156E001993 install -r build/app/outputs/flutter-apk/app-debug.apk`. It
  auto-locks; Thomas unlocks it.
- **Emulator** (canonical note: checkfuchs memory `reference-android-emulator`): launch
  *inside* the distrobox, in the background —
  `distrobox enter flutter -- bash -lc '$HOME/Android/emulator/emulator -avd knabber -gpu host -no-snapshot -no-boot-anim -no-audio'`.
  It's x86_64: build `--target-platform android-x64`, and start the app with Impeller
  off (`adb -s emulator-5554 shell am start -n ch.fuchsnest.launenfuchs/.MainActivity --ez enable-impeller false`,
  or `flutter run --no-enable-impeller`), otherwise the surface stays 0×0.
  Screenshots: `adb exec-out screencap -p > .emu_x.png` (gitignored).
- **Release flow (copied from checkfuchs, same model):** write the four changelogs at
  `fastlane/metadata/android/<locale>/changelogs/<nextBuildNumber>.txt` and the iOS
  `release_notes.txt`, then `tool/cut_release.sh x.y.z`. **The tag is the human gate**:
  `android.yml` / `ios.yml` run on `v*` tags only. Store text and lanes:
  `fastlane/RELEASING.md`. Secrets (keystore, `android/key.properties`,
  `fastlane/play-store-key.json`, `*.p8/*.p12`) are gitignored — never commit, print or
  paste them; backups in ProtonDrive, CI copies as base64 secrets.
- **Schema:** still v1 and pre-release-mutable until the first store build; after that
  every change is a drift migration (`schemaVersion` + `onUpgrade`).
- **Landing / privacy pages:** `docs/` (GitHub Pages; planned domain
  launenfuchs.fuchsnest.ch, no CNAME yet).
- **Store screenshots:** not automated yet (checkfuchs' `tool/screenshots.sh` needs an
  `integration_test` harness + demo data — use invented data, never the real backup).

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
