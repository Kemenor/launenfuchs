# UI examples — visual canon

Static, self-contained HTML mockups of Launenfuchs's core surfaces, built against
[`../../DESIGN_SYSTEM.md`](../../DESIGN_SYSTEM.md). **These are the visual reference** until
the Flutter widgets exist.

Open any file in a browser — each has a **light/dark toggle** (top-right). Fonts (Figtree,
Material Symbols) stream from Google Fonts. Shared styles: `fuchsbau.css` (copied from
knabberfuchs, reset to plain Fuchsbau, plus the mood scale).

| File | Surface |
|---|---|
| `01-journal.html` | First run (mood row + Daylio import offer) · Journal: month calendar with mood dots and **period bands**, entry list, `Log today` / `Edit today` FAB · the **period hint** when none is ongoing (toggle above the phone) · **New period** from a range selected in the calendar |
| `02-entry.html` | Entry sheet (**interactive**): mood picker (ring, not indigo fill), *one* vs *any* categories, chips or a **stepped slider** (unset state, ×), **pending defaults** in neutral with a DEFAULT tag that are **saved** like any pick (try Save, then ↺ new entry), the after-midnight "yesterday" default |
| `03-stats.html` | Stats as **customizable tiles** (checkfuchs pattern): range row, Summary, Day by day, By period (+ Period / edit), Mood alongside what you logged, Weekday bars, Ups and downs, Good and hard stretches · **Edit tiles** · **Option detail** (Walk: frequency strip, mood same/next day, often together, by period, runs) |
| `04-settings.html` | Settings (no periods) · category editor (one per day, show as, tracked since, options with the DEFAULT tag, fill empty days, remove) · option menu · **Remove: Hide (data kept) vs Delete for good** · **Merge into…** confirmation · *New day starts at* setting |
| `05-import.html` | Daylio import stepper: Categories (keep / merge / drop, suggested modes) · Options (rename, merge, drop; unused start on Drop) · Defaults & empty days (fill 15 days with Day off) · Review (mapping saved) |

All sample data is **invented** (periods *Normal weeks · Holiday · Moving flat · New job*, categories *Work · Health · Social · Hobbies · Coffee*) — no real journal data in this repo.

> Throwaway HTML for *design decisions*, not production code.
