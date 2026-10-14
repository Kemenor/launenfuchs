# Launenfuchs — Plan

A **mood journal** with free, honest statistics. Rate the day, tap what you did, maybe a
note — then see what moves your mood, on your phone, without a subscription. Android-first
(Flutter, iOS kept possible). Local-first, serverless, no accounts, no ads.

The model lives in [`design-concept.md`](./design-concept.md) — that doc owns the *what*.
**This doc owns the *how*:** stack, schema, engine, and the phased build order.

> Status: **Phase 0 done** (2026-10-14) — skeleton boots to an empty Journal (phone + emulator), 21 tests green. Next: Phase 1. Launcher icon pending the
> art (Phase 0's one open item).

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
| Reminders | `flutter_local_notifications` + `timezone`; one daily, cancelled once today is logged |
| Import | Daylio `.daylio` reader in `data/import/`: pure parser → **import plan** (the user's mapping applied) → one transaction. Mapping persisted for repeat imports. Tested against a fixture |
| Backup | Fuchsbau pattern: ZIP (SQLite snapshot + JSON) with manifest; save dialog out, `flutter_file_dialog` in |
| Report | **HTML + PDF from one source**: the report is a self-contained HTML string built from engine view models (inline CSS/JS, print stylesheet); PDF = `printing`'s `Printing.convertHtml` on that same HTML. Both written through the save dialog |
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
              action TEXT 'keep'|'merge'|'drop', target_id INT NULL, name TEXT NULL,
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

| # | Phase | Done when |
|---|---|---|
| 0 | **Skeleton** — repo, fuchsbau theme, l10n, drift v1, CI (analyze, test, format, codegen fresh), launcher icon | app boots to an empty Journal in 4 locales, dark + light |
| 1 | **Log** — starter categories, entry sheet (mood, one/any, chips/slider, stored defaults, note), Journal month + list, edit/delete | a day can be logged in < 10 s; a default is saved as an option |
| 2 | **Daylio import** (5-step mapping, saved mapping) + backup export/import | a real backup imports with a renamed default, unused options dropped and empty days filled; a repeat import asks nothing; backup round-trips identically |
| 3 | **Stats I** — engine + golden fixture; tile framework + Edit tiles; Summary, Day by day, Mood alongside, Weekday, Notes; option detail | engine numbers match the 2026-10-14 report |
| 4 | **Periods** — range select in the calendar, period sheet, bands on charts, *By period* card with + / edit, grid | a multi-period split of the reference report reproduces |
| 5 | **Category editor** — mode, show as, default option, tracking spans, fill empty days, hide / bring back / delete for good (categories and options), merge options, icons; reminder | changing a default leaves past days untouched; a hidden-then-restored category shows the gap as *not tracked* |
| 5a | **App lock** — `local_auth`, lock on open / on resume after the delay, hidden recents preview | locked on cold start and after the delay; device PIN works when biometrics fail |
| 5b | **Stats II** — Mood count, Option counts, Often together, Ups and downs, Good and hard stretches, Year in pixels | each tile has a golden test |
| 6 | **Report** — range, sections, notes toggle, periods; HTML, then PDF from the same HTML | a report for a therapist in < 30 s; HTML and PDF show the same numbers |
| 7 | **Release** — store listing, fastlane, landing page, screenshots | internal track build |

Phases 1–3 are the useful core: after 3 the app replaces Daylio for daily use *and* the
paywalled stats.

## Decided (2026-10-14)

- **One entry per day.** `entry.day UNIQUE`.
- **Day cut-off 04:00 by default, a setting** (`setting.day_cutoff_hour`).
- **Report: HTML and PDF**, the PDF rendered from the HTML.
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
