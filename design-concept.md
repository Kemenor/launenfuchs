# Launenfuchs — Design Concept

The conceptual model: **what** the objects are and what they mean. [`PLAN.md`](./PLAN.md)
owns the *how* (stack, schema, phases). When the two disagree, this doc wins for
semantics.

> Status: **reviewed** (2026-10-14, rev. 3 — options, stored defaults, mapping import,
> periods out of Settings, hide vs. delete, tiles, app lock, starter set). Decisions are
> logged in PLAN.md § Decided.

---

## 1. Why this app exists

A mood journal is a small database with a fast entry screen and honest charts. Daylio
does the entry screen well but puts the charts — the reason you log at all — behind a
subscription. Launenfuchs is the fuchs answer: **log a day in ten seconds, and every
statistic is yours, on your phone, free.**

It is built from one real use: preparing for a therapy session by looking back over
five weeks of entries. That session shaped the stats in §5 — they are the views that
actually answered questions, not a feature checklist.

### 1.1 Values (on top of the Fuchsbau ethos)

- **Ten-second logging.** Mood, a few taps, optional note, done. The reminder opens
  straight into today's entry.
- **Low mood is data, never a verdict.** No red, no "streak lost", no nagging about a
  missed day. A bad week is shown as plainly as a good one.
- **Observations, not advice.** Stats say what happened together ("on walk days your
  average was 4.1"), never why, never what to do. Every comparison view carries the
  same quiet caveat.
- **Absence is not zero.** "Nothing logged" and "not tracked yet" are different from
  any option — the stats keep them apart (§4.3). This was the biggest trap in the real
  data.
- **What you saved stays saved.** Defaults are written into the entry; changing a
  setting later never rewrites past days behind your back.
- **Your data is a file you own.** Daylio backups import (with your mapping); everything
  exports.

---

## 2. Objects

```
MoodLevel (fixed 5)      Category ──< Option
      │                     │           │
      └──── Entry (one per day) >───────┘   (entry ⇄ options, many-to-many)
                │
             Period (named date range; overlaps allowed)
```

Naming: a **category** is something you track (*Work*, *Coffee*, *Health*); its
**options** are the values it can take (*worked less*, *two cups*, *walk*). Not
"activities" — *no coffee* or *sick* aren't things you do, just things you note.

### 2.1 Mood level
- A **fixed five-step scale**, stored as `1…5`, **5 = best** (Daylio stores it the other
  way round — import flips it).
- Each level has a **label** and an **icon**; defaults *awful · bad · meh · good · rad*
  (localised), both user-renameable. The *value* never changes, so stats stay comparable.
- Custom number of levels (3 or 7) — **out for v1**; five matches Daylio.

### 2.2 Entry
- **One entry per calendar day** (decided 2026-10-14): a day is rated once, usually in
  the evening. Fields: `day` (local date), `time` (when it was logged, display only), `mood`,
  `options`, `note`.
- `note` is plain text, optional. No photos in v1.
- Entries are **freely editable** — a journal, not a ledger. `updatedAt` is kept.
- Logging after midnight for the evening before is normal: the entry sheet shows the day
  and defaults to **yesterday until the cut-off hour** — 04:00 by default, a setting
  (Settings › Journal › *New day starts at*).

### 2.3 Category
- A named group of options, in user order, with an icon.
- **Selection mode** — the feature Daylio paywalls:
  - **one per day** — choosing an option replaces the previous one (Work, Sleep,
    Coffee).
  - **any number** — independent toggles (Health: walk, gym; Hobbies).
- **Show as** (one per day only): **chips** (default) or a **stepped slider**. The slider
  turns the option order into a scale, left to right (Coffee: none → one → two →
  three+). Pure presentation — flipping it never touches history.
- **Default option** (one per day only, optional) — e.g. *Day off* for Work. Pre-selected on **new** entries, and **saved into the entry like any
  other pick** (§3). Changing the default later affects only entries created after the
  change.
- **Tracking spans** — the date ranges in which this category counts: `[from, to]`, the
  last one usually open. Days outside every span are *not tracked*. A new category opens
  a span on its creation day; import opens one at the first use (*Tracked since*).
- **Removing a category is a choice** (one dialog, both options spelled out):
  - **Hide** — gone from the entry sheet, **data kept**, still in stats for the days it
    was tracked. Closes the current span. **Bring it back** later opens a new span — so
    the hidden months read *not tracked*, never *nothing logged* (stopping and restarting
    tracking coffee must not make the gap look coffee-free).
  - **Delete for good** — the category, its options and their values on every day are
    removed. Red, shows the number of days affected, Cancel → Confirm. Not undoable
    (a backup is).
  Daylio only offers the second; losing months of data to tidy a list is the wrong
  default.
- **Fill empty days…** — an explicit editor action: set every tracked day that has
  nothing from this category to one chosen option. Shows the day count first, one
  confirmation. The only way past entries change in bulk, and only because you said so.

### 2.4 Option
- Belongs to one category; name + Material Symbols icon; order; hidden flag.
- **Identity is the id**: renaming renames it everywhere in history.
- **Merge into…** another option (same or other category): moves its days over, then
  deletes it — for cleaning up duplicates later. **Irreversible**, so it confirms first
  with the numbers ("Moves 1 day from *sport* to *Gym* and deletes *sport*. Can't be
  undone.") and a red confirm button. If the target is in a *one per day* category and
  some days would end up with two options, the dialog says how many and keeps both
  (§4.3). (In the import, merging is just part of the mapping — nothing is written until
  Review, and the Daylio file stays untouched.)
- Removing an option offers the same two paths: **Hide** (gone from the entry sheet,
  past days keep it, *Bring back* restores it) or **Delete for good** (removed from every
  day; red, day count, Cancel → Confirm). An option no day uses is simply deleted.

### 2.5 Period
- A named, inclusive **date range** — *Holiday*, *Moving flat*, *New job*. `end` may
  be open ("ongoing").
- Periods **may overlap** (a *Summer* period containing *Holiday*).
- Optional flag **away / off** — shaded on charts and the calendar.
- Periods never change entries; they slice stats (§5).
- **Where they live — not in Settings.** Periods are about time, so they're made and seen
  where time is:
  - **Journal calendar:** long-press a day, drag (or tap the end day) to select a range
    → *New period* sheet (name, away/off, ongoing). Periods show as a band under the
    calendar days; tap the band → edit.
  - **The gesture is taught, not hidden:** while **no period is ongoing**, the calendar
    card ends with a hint — *"Mark a stretch of days as a period — a holiday, a new job,
    a hard month. Long-press a day, then drag."* The *By period* tile's empty state says
    the same plus a *+ Period* button.
  - **Stats:** the range picker lists periods; the *By period* card has *+ Period* and an
    edit affordance; tapping a band on any chart opens that period.

### 2.6 App lock
- Optional, **off by default** (Settings › Privacy). When on, the journal opens only
  after the phone's own unlock — fingerprint / face, with the device PIN as fallback. No
  separate app password to forget.
- Locks on open and when you come back after a chosen delay (*immediately* · *1 min* ·
  *5 min*). While locked, the app's preview in the recent-apps list is hidden.

### 2.7 Starter categories (fresh install, no import)
A neutral set, all editable and removable; shown once on first run with "change any of
these later":

| Category | Mode | Options |
|---|---|---|
| Work | one per day, chips | Worked normally · Worked less · Day off *(default)* · Sick |
| Health | any number | Walk · Exercise · Sport |
| Social | any number | Friends · Family · Partner · Time alone |
| Hobbies | any number | Read · Gaming · Music · Creative |
| Sleep | one per day, slider | Poor · OK · Good |

### 2.8 Reminder
- One daily local notification at a chosen time (default 20:00). Tapping opens today's
  entry sheet. If today is already logged, it's cancelled for today. No follow-ups, no
  "you missed yesterday".
- On Android it shows the **five moods** (worst → best, like the entry sheet): a face
  opens today's entry with that mood picked — nothing is saved until Save, so defaults
  and options work as always. iOS keeps the plain notification.

---

## 3. The entry sheet (the 80 % action)

1. **Mood row** — five faces, one tap. Required; everything else is optional.
2. **Categories** in user order. *one per day* → single-choice chips or a stepped slider;
   *any number* → toggle chips. Tapping a selected option clears it.
3. **Defaults on a new entry.** A *one per day* category with a default shows that option
   **pre-selected in neutral grey with a small DEFAULT tag** — "this is what gets saved
   unless you change it". Pick another option to replace it, or tap it to clear the
   category (*nothing logged*). On **Save**, whatever is selected — default included — is
   stored. Reopening the entry shows it as an ordinary selection; the default styling only
   ever appears on an unsaved new entry.
4. **Sliders without a default start unset** (faded track, no thumb, value "–") — an
   untouched slider must mean *nothing logged*, never the leftmost option. With a default,
   the thumb starts on it in neutral. A small × clears either way.
5. **Note** — collapsed single line, expands on focus.
6. **Save** (full-width). Mood alone is a complete entry.

Editing a past day opens the same sheet with what was stored — defaults are not re-applied
to existing entries, and categories that didn't exist yet on that day are shown but empty.

---

## 4. Semantics the stats rely on

### 4.1 Score
`score = mood value (1…5)`. Averages are arithmetic means, shown to one decimal, always
with the number of days behind them.

### 4.2 Day-level facts
For every day `D` in a range: logged / not logged; if logged, its score and its options.

### 4.3 Category state on a day (the "absence is not zero" rule)
For category `C` and logged day `D`, exactly one of:

| State | Condition | Shown as |
|---|---|---|
| **not tracked** | `D` outside every tracking span of `C` | "not tracked" (muted, hollow) |
| **nothing logged** | tracked, no option of `C` on `D` | "nothing logged" (muted, hollow) |
| **option(s)** | one (or more) options of `C` | the option names |

A default that was saved is an **option**, not *nothing logged*. A *one per day* category
with two options on a day (after a mode switch or a merge) counts the day under each —
stats never hide history.

### 4.4 Comparisons
- **any number** categories: an option's average vs. the overall average of the range.
- **one per day** categories: the options are compared **with each other** (plus the
  *nothing logged* row); the overall average is a reference line only.

---

## 5. Stats

### 5.1 One screen, made of tiles (the checkfuchs pattern)
Stats is a column of **tiles**, all scoped to one **range** chosen at the top (30 days ·
month ‹ › · year · all · custom · a period). The `tune` icon opens **Edit tiles**: every
tile as a switch row in display order, drag to reorder, off tiles at the bottom. New tiles
land there as they ship. Order and on/off are persisted. Tapping an **option** anywhere
in Stats opens its detail page (§5.3).

### 5.2 The tile catalogue

On by default, in this order — the views that answered the real questions:

| Tile | Shows |
|---|---|
| **Summary** | average, days logged / days in range, best and worst day; one figure per pinned period |
| **Mood, day by day** | a dot per day (colour + face), 7-day trailing average, period bands (*away/off* shaded), note rings. Tap a dot → the entry; tap a band → the period |
| **By period** | 100 % stacked bar per period (+ "outside any period"), average on the right; **+ Period** and edit live here |
| **Mood alongside what you logged** | per §4.4, grouped by category, `n` on every row, `n < 2` hidden, *nothing logged* / *not tracked* as hollow dots, the fixed caveat underneath |
| **What you logged, day by day** | grid: options × days, mood strip on top, period bands behind |
| **Weekday** | average mood per weekday as bars; says "no weekday pattern" in words when the spread is under 0.5 |
| **Notes** | every note in range, newest first, with mood |

Off by default, one switch away (several inspired by Daylio, reworked where needed):

| Tile | Shows | vs. Daylio |
|---|---|---|
| **Mood count** | five faces with a count each + a proportional bar | same |
| **Option counts** | every option with its count, then per-category totals; tap → detail | same, grouped by category |
| **Often together** | pick a mood → the options most often logged on those days, with counts | same |
| **Ups and downs** | how much mood moves day to day, in words and numbers: "on average 0.8 steps from one day to the next", the biggest drops with their dates, a small chart of the changes | **replaces "Mood stability 35/100"** — an opaque score reads like a grade; this shows what it measures |
| **Good and hard stretches** | the longest run of good-or-better days and of bad-or-worse days, with dates and what was logged during them | **replaces "Longest best day streak"** — information about your weeks, not a streak to protect; the hard stretch matters as much |
| **Year in pixels** | one square per day, mood colour, period bands | Daylio's classic |

Tone rules for every tile: counts and averages with `n`; no red; a trend is an arrow and
a number, never a verdict colour.

### 5.3 Option detail (tap any option)
A pushed page for one option in the current range — Daylio's per-activity page, minus
the paywall:
- **Frequency strip** — the days of the range, coloured by mood where the option was
  logged, grey otherwise; count, the previous equal range's count, and the change
  (neutral arrow).
- **Mood on those days** — distribution + average vs. the overall average.
- **Same day / next day** — average mood on days with it and on the day after, each with
  `n` and the caveat. (Daylio's "day before / same / day after".)
- **When in the week** — count per weekday.
- **Often together with** — the options most often logged on the same days, as "% of its
  days".
- **Longest run** with it and without it (for tracked days only).
- **By period** — how often it appeared in each period (the walks-mostly-on-holiday kind of
  insight).

No streaks, badges or achievements anywhere. *Days logged* is a plain count.

---

## 6. Report (for someone else)

An explicit export for a therapist, doctor or yourself: pick a range (default: since the
last report, else 30 days), the sections (default: the tiles currently on in Stats),
**include notes: off by default**, and which periods to show. Output, both from **one
source** (decided 2026-10-14):

- **HTML** — a single self-contained file like the 2026-10-14 page: interactive
  tooltips, light/dark, opens on any phone or laptop, works offline.
- **PDF** — the same sections, numbers and charts, laid out for print, for printing or
  attaching.

Saved via the system save dialog. Nothing is sent anywhere by the app.

---

## 7. Import from Daylio

Daylio's CSV export is premium; its **backup is free**, and that is what we read. The
import is a **mapping**, not a copy: Daylio's structure is a starting point you reshape
on the way in.

### 7.1 Format
A `.daylio` file is a ZIP holding `backup.daylio`, which is base64 of a JSON document
(`version` 15 seen 2026-10). Used keys: `customMoods`, `tags`, `tag_groups`, `dayEntries`.
Mood `mood_group_id` 1…5 → value `6 − group`; dates from `year`/`month + 1`/`day` (months
0-based); `note_title` + `note` → note (`<br>` → newline, other HTML stripped).

### 7.2 The import flow (a full-screen stepper)
1. **File** — pick the backup; show what's in it: days, date range, notes, photos
   (skipped), days with several Daylio entries.
2. **Categories** — one row per Daylio group, with its use count:
   **Keep** (rename · mode one/any, suggested from the data · show as) ·
   **Merge into ▾** another category · **Drop** (its options leave every entry; count
   shown).
3. **Options** — one row per Daylio tag, grouped under its target category, with use
   count and first/last use: **Keep** (rename, icon) · **Merge into ▾** any option ·
   **Drop**. **Never-used tags are pre-set to Drop.** A merge that would give a *one per
   day* category two options on the same day shows the count and keeps both (§4.3).
4. **Defaults & empty days** — per *one per day* category: the default option for new
   entries; *Tracked since* (pre-set to first use); and **days with nothing logged** →
   *leave as nothing logged* or *fill with ▾ option* (e.g. untagged Work days on weekends
   and holidays → *Day off*). Filled days are stored, per §1.1.
5. **Review** — final numbers, then **Import into an empty journal** or **Replace
   everything** (one explicit confirmation, Fuchsbau backup rule).

### 7.3 Saved mapping, repeat imports
The mapping (Daylio group/tag id → keep/merge/drop + names) is **saved**. Importing a
newer Daylio backup reuses it and only asks about groups/tags it hasn't seen — so
switching over can take weeks without redoing the setup. A repeat import still
*replaces*; merging into a journal you've already started comes **later** — it needs a
per-day conflict rule.

### 7.4 Skipped, and said so
Photos (`assets`), goals, achievements, reminders, writing templates. Several Daylio
entries on one day become one: mean mood rounded half up, union of options, notes joined
in time order — the File step says how many days that affected.

---

## 8. Out of scope for v1

Photos · several entries per day · custom scale length · goals / streaks / achievements
· writing templates · sync of any kind · home-screen widget *(v2 candidate)* · merging an
import into a non-empty journal *(later)* · slider stats (a scale category's level
charted next to mood) *(later)*.
