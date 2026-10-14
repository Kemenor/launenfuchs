# Launenfuchs — UI Design System

**Inherits the [Fuchsbau design system](../fuchsbau/DESIGN.md).** Colours (the tangerine
triad), typography (Figtree + the accessibility font picker), spacing/shape/elevation,
Material Symbols Rounded, and the base component patterns (pill FAB, 28-sheets,
destructive-never-on-swipe) all come from there. This doc records only what's
launenfuchs-specific.

Canonical mockups: [`examples/ui/`](./examples/ui/) — the visual canon until widgets
exist.

> **Deviations from Fuchsbau: one** — the mood scale (§1), a five-step data palette the
> bau doesn't define. Everything else is used as-is.

---

## 1. Mood scale (deviation)

Fuchsbau reserves red for destruction, so low mood can't be red the way Daylio does it.
The scale runs **emerald (good) → neutral grey → indigo (low)**: two triad hues and the
bau's neutral, read as *"bright ↔ blue"*, never *"pass ↔ fail"*.

| Level | Value | Icon (Symbols Rounded) | Light | Dark |
|---|---|---|---|---|
| rad | 5 | `sentiment_very_satisfied` | `#1FA85D` emerald | `#37CE78` |
| good | 4 | `sentiment_satisfied` | `#84CFA6` emerald 55 % on card | `#2E8650` emerald 60 % on card |
| meh | 3 | `sentiment_neutral` | `#8C857E` neutral | `#9A938C` |
| bad | 2 | `sentiment_dissatisfied` | `#BCA4E5` indigo 55 % on card | `#735E97` indigo 60 % on card |
| awful | 1 | `sentiment_very_dissatisfied` | `#8559D0` indigo | `#A98CEE` |

- **Never colour alone.** A mood is always shown with its **face icon** (and its label
  wherever there's room). Validated 2026-10-14: adjacent steps are colour-blind-safe in
  both themes (worst ΔE 14.5 light / 9.9 dark), but *good* and *bad* fall below 3:1 on
  the light card — the icon carries them.
- **Selection is not indigo fill** in the mood picker (indigo = *awful* here): the
  selected face gets a 2 px `onSurface` ring and scales to 1.15×; the others dim to 60 %.
- Charts use these colours for mood marks only; option marks use **primary orange**,
  period bands use **amber 12 %** (information, Fuchsbau's amber role).

## 2. Screens

### 2.1 Journal → `examples/ui/01-journal.html`
- Top: month calendar, each day a small mood-coloured dot, today tinted orange.
  **Periods** run as a thin labelled band under their days (amber when *away/off*,
  outline otherwise); tap a band → edit that period.
- **Range select → new period:** long-press a day, then drag or tap the end day; the
  range highlights (orange 12 %) and a sheet asks for name, *away/off*, *ongoing*.
- **Period hint** — while no period is ongoing, the calendar card ends with one muted
  line + `date_range` icon: *"Mark a stretch of days as a period — a holiday, a new
  job, a hard month. Long-press a day, then drag."* Gone as soon as a period is ongoing
  (the legend takes its place).
- Below: entries newest first — row = face · date · option icons · first line of note.
- **FAB**: extended pill **`+ Log today`** (becomes **`Edit today`** once logged).

### 2.2 Entry sheet → `examples/ui/02-entry.html`
- Fuchsbau sheet (28 top, drag handle, `isScrollControlled`, ✕ top-right).
- Day header with ‹ › to move between days ("Yesterday" until the cut-off hour).
- Mood row (§1), then one block per category: **title + mode hint** ("one" / "any"),
  option chips (icon + label). *one* = single-choice, *any* = toggles; tapping a selected
  chip clears it.
- Selected chip = orange 15 % tint, orange label (Fuchsbau chip). Hidden options don't show.
- **Pending default** (new entry only): the category's default option, in its normal place
  in the row, pre-selected in **neutral** `#8C857E`/`#9A938C` 18 % fill, ink label,
  neutral icon and a small uppercase `DEFAULT` tag. Neutral, not orange: "this gets saved
  unless you change it", not "you chose this". **It is saved like any pick**; a stored
  entry never shows the DEFAULT styling again.
- **Slider** (a *one* category set to *Show as: Slider*): discrete M3 slider, one stop per
  option, labels under the stops, current value right-aligned in the category header.
  **Unset** (no default) = faded track, no thumb, value "–" in muted. **Pending default**
  = thumb on the default in neutral, header value in neutral. A trailing `close` icon
  clears it (hidden while unset). More than **5 stops**: only the two end labels show
  (the header carries the value).
- Note field, then full-width **Save**. Mood is the only required input.

### 2.3 Stats → `examples/ui/03-stats.html`
- App bar: *Stats*, `tune` (→ Edit tiles), `ios_share` (→ report).
- Range row under it: chips *30 days · Month · Year · All · Period ▾*; *Month* shows
  ‹ October › to step. The *Period* menu lists periods and ends with *+ New period*.
- **Tiles** = `lg`(20) cards (the checkfuchs stats pattern): small uppercase title, a
  drag handle at the right of the title row, content below. Every chart has tap
  tooltips and an "as a table" toggle; tapping a period band opens that period's sheet;
  tapping an option opens its detail page.
- **Edit tiles** (pushed screen): a hint line, then one switch row per tile with a drag
  handle, in display order; off rows sink below a hairline. Same as checkfuchs §09.
- *By period* tile header carries **`+ Period`** (text button) and an `edit` icon. Empty
  state: the period hint text + a tonal `+ Period` button.
- *Nothing logged / not tracked* rows: hollow muted dots, italic label.
- The caveat line sits under *Mood alongside what you logged* in `bodySmall` muted —
  always visible, never dismissible.
- **Trends** (option detail, counts vs. previous range): `arrow_upward` /
  `arrow_downward` + number in ink — never red/green verdict colours.
- **Option detail** (pushed): app bar = option icon + name with a ▾ switcher; sections as
  tiles in fixed order (not customizable — it's a drill-down, not a dashboard).

### 2.4 Settings → `examples/ui/04-settings.html`
- Groups: **Journal** (categories & options · reminder · new day starts at) · **Privacy**
  (app lock + its delay) · **Data** (import from Daylio · backup export/import · report)
  · **Look** (theme · font) · About. **No periods here** —
  they live in Journal and Stats.
- Category editor: name + icon, **"Pick one per day"** switch, **Show as** segmented
  *Chips · Slider* (one-per-day only; hint "the options below, left to right, become the
  steps"), *Tracked since* date, the options list (drag to reorder; the default carries a
  `DEFAULT` tag — set via the row's menu: *Make default · Rename & icon · Merge into… ·
  Remove…*), then **Fill empty days…** as a text button (count + confirmation before
  writing), and **Remove category…** last.
- **Merge dialog** (option menu › *Merge into…*): a target picker (options grouped by
  category), then the consequence in words — "Moves 1 day from *sport* to *Gym* and
  deletes *sport*. Can't be undone." — an amber info line when a *one per day* target
  would get two options on some days, and **Cancel → Merge** with Merge in error red
  (it deletes an option).
- **Remove dialog** (category or option): two stacked choices, not a yes/no —
  **Hide** (`visibility_off`, "Data kept. Bring it back any time; the gap counts as not
  tracked.") as the `FilledButton`, then **Delete for good** (`delete`, error red, with
  the day count: "Removes Coffee from 25 days."), then *Cancel*. Delete for good asks
  once more. Hidden categories and options are listed at the bottom of the editor list
  under *Hidden* with *Bring back*.

### 2.5 Daylio import → `examples/ui/05-import.html`
- A **full-screen stepper** (not a sheet — it's a task): app bar *Import from Daylio*,
  a step indicator *File · Categories · Options · Defaults · Review*, Back / Next as the
  bottom bar.
- **Mapping rows**: name (editable) + use count on the left; on the right a compact
  segmented **Keep · Merge · Drop**. *Merge* reveals a target picker (`→ Gym`);
  *Drop* strikes the name in taupe and shows what's lost ("removed from 4 days"). Never-used rows start on *Drop*.
- Warnings (same-day collisions after a merge, days losing data) are amber info lines,
  never red — red appears only on the final *Replace everything* confirmation.
