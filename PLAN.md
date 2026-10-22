# Launenfuchs — Plan

A **mood journal** with free, honest statistics. Rate the day, tap what you did, maybe a
note — then see what moves your mood, on your phone, without a subscription. Android-first
(Flutter, iOS kept possible). Local-first, serverless, no accounts, no ads.

The model lives in [`design-concept.md`](./design-concept.md) — that doc owns the *what*.
**This doc owns the *how*:** stack, schema, engine, and the phased build order.

> Status: **v1.0.0 feature-complete** (2026-10-15) — Phases 0–6 done, release tooling in
> place, 74 tests; not published yet (§ Release — what's left).

## Decisions

| Area | Decision |
|---|---|
| Framework | **Flutter**, same toolchain as the siblings (distrobox `flutter`) |
| Base | **fuchsbau** package (theme, fonts, choice picker, settings scaffolding) |
| State | **Riverpod** (v3) |
| Persistence | **drift / SQLite**, migrations from v1 |
| Domain core | **Pure stats engine** over an injected `Clock`: entries + categories + periods in, view models out. No Flutter, no drift — fully unit-tested with fixtures. **Committed fixtures are synthetic.** The author's real Daylio backup is a *local-only* golden test (`test/private/`, gitignored, skipped when absent) — mood data never goes into a public repo |
| Charts | **Hand-drawn `CustomPainter`s**, no chart package — the views are specific (period bands, ringed note dots, hollow "not tracked" rows) and few. Revisit if it drags |
| Navigation | Router-less: bottom `NavigationBar` **Journal · Stats · Settings**, `push` for sheets |
| Reminders | Android: native `Reminder.kt` (inexact `AlarmManager` alarms, a custom layout with the five mood faces — the plugin can't do custom views; faces drawn by `tool/make_notification_faces.py`). iOS: `flutter_local_notifications` + `timezone`. One daily, cancelled once today is logged |
| Import | Daylio `.daylio` reader in `data/import/`: pure parser → **import plan** (the user's mapping applied) → one transaction. Mapping persisted for repeat imports. Tested against a fixture |
| Backup | Fuchsbau pattern: ZIP (SQLite snapshot + JSON) with manifest; save dialog out, `flutter_file_dialog` in |
| Report | **HTML + PDF from the same building blocks**: a self-contained HTML string (inline CSS + SVG, no scripts, no requests) and a PDF laid out with the `pdf` widgets from the same engine numbers and the same SVG charts (literal print colours), Atkinson Hyperlegible from fuchsbau. *(The first plan — `printing`'s `convertHtml` on the HTML — is deprecated and hangs on current Android: it relies on hidden print APIs. Found 2026-10-14 on the emulator.)* Both written through the save dialog |
| l10n | en / de / fr / it from day one |
| Keys | `INTEGER` autoincrement; days stored as ISO `TEXT` (`2026-10-14`) — a calendar date, not an instant |
| App id | `ch.fuchsnest.launenfuchs`; landing page under fuchsnest.ch |
| Min SDK | Android API 26 (family baseline) |
| Repo | `Kemenor/launenfuchs` *(to create)* |

## Architecture

```
lib/
  core/        theme (→ fuchsbau), clock, date/day helpers, formatting
  data/
    db/        drift tables + DAOs + migrations
    repositories/  entries · categories/options · periods · settings
    import/    daylio/  (zip → base64 → json → DaylioBackup) · plan/ (mapping → ImportPlan)
    backup/    ZIP snapshot + JSON export/import
    report/    PDF builder (consumes engine view models only)
  domain/      PURE: day facts, category state (§4.3), averages, rolling mean,
               period slices, option comparison, weekday, range math,
               import planning (mapping + backup → plan, with counts for the UI)
  ui/
    journal/   month calendar (+ range select → new period) + list, entry sheet
    stats/     sections + painters, period sheet
    import/    the Daylio stepper
    settings/  categories & options, reminder, import/export, report, fonts, theme
  l10n/
```

## Schema (drift, v1)

```
mood_label   (value INT PK 1..5, label TEXT NULL, icon TEXT NULL)   -- NULL = localised default
category     (id, name, icon TEXT, mode TEXT 'one'|'any', display TEXT 'chips'|'slider',
              default_option_id → category_options NULL, sort INT, hidden BOOL)
category_span (id, category_id → category ON DELETE CASCADE, from_day TEXT,
               to_day TEXT NULL)          -- hide closes the open span, bring back opens one
category_options (id, category_id → category ON DELETE CASCADE, name, icon TEXT, sort INT,
              hidden BOOL)
entry        (id, day TEXT UNIQUE, logged_at INT, mood INT 1..5, note TEXT NULL,
              created_at INT, updated_at INT)
entry_options (entry_id → entry ON DELETE CASCADE, option_id → category_options ON DELETE CASCADE,
              PK(entry_id, option_id))     -- "delete for good" = the cascade
period       (id, name, start_day TEXT, end_day TEXT NULL, away BOOL, icon TEXT NULL)
import_map   (source TEXT 'daylio', kind TEXT 'group'|'tag', source_id INT,
              action TEXT 'keep'|'merge'|'drop', target_id INT NULL, choice TEXT JSON NULL,
              PK(source, kind, source_id))
app_settings (id = 1, theme, font, locale, day_cutoff_hour, stats_tiles JSON, app_lock, …)   -- singleton row (checkfuchs pattern)
```

`entry.day UNIQUE` encodes *one entry per day* — dropping it later (if several entries
per day are wanted) is a migration, not a rewrite. "One per day" selection is enforced
in the repository (replace-on-select), not by a DB constraint, so a mode switch never
breaks history.

**Defaults are written, not inferred.** `category.default_option_id` only drives the
entry sheet's pre-selection; saving writes a real `entry_option` row. Nothing in the
stats engine reads the default, so changing it can't move past numbers. *Fill empty
days…* and the import's *fill with* are plain bulk inserts behind a confirmation.

## Engine

`domain/` exposes one entry point per stats section, each a pure function of
`(entries, categories, options, periods, range)`:

- `daySeries` → per-day score + 7-day trailing mean (partial window at the start).
- `periodSummary` → distribution + mean per period, plus "outside any period".
- `optionComparison` → grouped rows per §4.4 with `n`, *nothing logged* and *not
  tracked* rows; `minN` filter applied in the view, not the engine.
- `weekdayMeans`, `optionGrid`, `notesInRange`, `summary`.
- Off-by-default tiles: `moodCounts`, `optionCounts`, `oftenTogether(mood)`,
  `upsAndDowns` (mean absolute day-to-day change over consecutive logged days, largest
  drops), `stretches` (longest runs ≥ good / ≤ bad), `yearInPixels`.
- `optionDetail(option)` → frequency strip, count vs. previous equal range, mood
  distribution, same-day / next-day means (each with `n`), weekday counts, co-occurrence
  ("% of its days"), longest run with / without (tracked days only), per-period counts.
- `planImport(backup, mapping)` → the entries/categories/options to write plus the counts
  every import step shows (uses, days affected by a drop, same-day collisions after a
  merge, empty days per category). The stepper is a view over this; the write is one
  transaction from the finished plan.

The HTML report built on 2026-10-14 is the reference for numbers: the local-only golden
test recomputes that report's figures from the real backup; the committed synthetic fixture covers the same shapes (periods, one/any
categories, a hidden-then-restored category, empty days, a tracked-from gap).

## Phases

| # | Phase | State (2026-10-15) |
|---|---|---|
| 0 | Skeleton — fuchsbau theme, l10n, drift v1, CI, launcher icon | ✅ |
| 1 | Log — starter set, entry sheet (chips/slider, stored defaults, note), Journal | ✅ |
| 2 | Daylio import (5-step mapping, saved mapping) + ZIP backup/restore | ✅ real backup imported on the emulator |
| 3 | Stats — engine + golden test, 13 tiles, Edit tiles, option detail | ✅ golden reproduces the 2026-10-14 report |
| 4 | Periods — calendar range select, bands, legend + hint, By period | ✅ |
| 5 | Categories (hide/delete, merge, fill, spans), reminder, app lock, mood names, About | ✅ unlock itself needs a real-device check |
| 6 | Report — HTML + PDF, notes off by default | ✅ real-data PDF verified |
| 7 | Release tooling — store text ×4 locales, workflows, landing + privacy pages, v1.0.0 | ✅ files; publishing open (below) |

## Release — what's left (needs Thomas)

1. **Upload keystore** for `ch.fuchsnest.launenfuchs` + `android/key.properties`, backed
   up to ProtonDrive (same recipe as checkfuchs).
2. **Play Console app record** + the first upload by hand (Play requires it), then the
   CI secrets (`ANDROID_*`, `PLAY_STORE_KEY_JSON_BASE64`).
3. **App Store Connect record** + signing secrets and `ios/ExportOptions.plist` (on the
   Mac, as for checkfuchs).
4. **GitHub Pages** for `docs/` and the launenfuchs.fuchsnest.ch DNS (store listings
   already point at its `/privacy.html`).
5. **Store screenshots** — an `integration_test` harness with invented demo data.
6. A **real-device pass**: fingerprint/PIN app lock, a reminder firing and its tap,
   import from the real Daylio file picker on the phone.

## Decided (2026-10-14)

- **One entry per day.** `entry.day UNIQUE`.
- **Day cut-off 04:00 by default, a setting** (`setting.day_cutoff_hour`).
- **Report: HTML and PDF**, same sections, numbers and charts (see Decisions › Report for why the PDF isn't literally rendered from the HTML).
- **Importing into a started journal: later.** v1 imports into an empty journal or
  replaces.
- **"Option"** is the word (German UI: *Option*, never *Tag*).
- **App lock in v1** — off by default; `local_auth` with the phone's own biometrics /
  PIN as fallback, no separate password. Locks on open and when returning after a chosen
  delay (immediately · 1 min · 5 min); while locked, the recents preview is hidden.
  Reminder notifications never show entry content (they don't anyway).
- **Several Daylio entries on one day** → one entry: mean mood rounded half up, union
  of options, notes joined in time order. Counted in the import's File step.
- **Slider stats: later.**
- **Starter categories (no import): a neutral set** — see design-concept §2.7.

## Open questions

None blocking Phase 0.

## Risks

- **Daylio format drift.** The backup is undocumented. Parse defensively, version-check,
  report unknown keys; keep the fixture so a format change is caught by a failing test.
- **Stats overreach.** The worst failure is a chart that implies a cause. Copy is
  reviewed against design-concept §1.1 before release.
