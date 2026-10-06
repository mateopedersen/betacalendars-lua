# Beta Calendars for Lua

Deterministic Gregorian calendar grids, bounded recurrence rules, business-day helpers, and date-boundary reports for Lua. The library is presentation-neutral, pure Lua, and works offline.

## Why this project exists

Calendar code often mixes date arithmetic with local timestamps or rendering. This package keeps civil dates as `{ year, month, day }` tables and returns stable structures that applications, games, command-line tools, and test suites can format as they need.

## Features

- Gregorian leap-year and month-length validation
- Timezone-independent weekdays and ISO week numbers
- Fixed six-row and compact month grids, with optional adjacent-month cells
- January-to-December year grids and consecutive date ranges
- Bounded weekly, monthly-day, nth-weekday, last-weekday, and annual recurrence
- Explicit `skip`, `clamp`, or `error` handling for missing monthly dates
- Weekend and caller-supplied excluded-date business-day helpers
- Year/month boundary reports
- Deterministic JSON, CSV, and Markdown exporters
- Optional `betacal` command-line application

## Installation

```sh
luarocks install betacalendars
```

## Quick start

```lua
local calendar = require("betacalendars")

local grid = calendar.month_grid(2027, 1, {
  week_start = "monday",
  fixed_rows = true,
  overflow = true
})

assert(#grid.cells == 42)
print(grid.cells[1].iso_date) -- 2026-12-28
```

Date values are plain tables. Validation rejects invalid dates and unsupported years outside 1 through 9999. No local clock, timezone, or daylight-saving conversion is used.

## Month grids

`month_grid(year, month, options)` returns a model with `cells` in reading order and a `weeks` array of rows. Each real cell includes its civil date, ISO date, weekday, row/column, month membership, weekend and boundary flags, and ISO week fields. `overflow = false` represents dates outside the month with `{ empty = true }` cells.

## Week starts and fixed six-row grids

`week_start` accepts a weekday name or integer from 1 (Monday) to 7 (Sunday). `fixed_rows` defaults to `true`, producing exactly 42 cells. Set `fixed_rows = false` to return only the four, five, or six rows the month requires.

## Year grids and date ranges

`year_grid(year, options)` returns twelve month models in calendar order. `date_range(from, to, options)` includes both endpoints by default; set `exclusive_end = true` to omit the last date. A `limit` can restrict range expansion (default 1,000,000 dates).

## Recurrence

`expand_recurrence(rule, from, to, options)` always requires a bounded date interval and has a default limit of 10,000 occurrences.

```lua
local mondays = calendar.expand_recurrence(
  { type = "nth_weekday", n = 1, weekday = "monday" },
  { year = 2027, month = 1, day = 1 },
  { year = 2027, month = 12, day = 31 }
)
```

Supported types are `weekly`, `monthly_day`, `nth_weekday`, `last_weekday`, and `annual_date`. For rules such as day 31, `invalid_day` is `skip` by default; `clamp` selects that month's last day, while `error` raises an error.

## Business days

Weekend days default to Saturday and Sunday. Supply `weekend = { "friday", "saturday" }` or weekday numbers to customize them. Add exact excluded dates as a map such as `{ ["2027-01-04"] = true }`. The library includes no holiday database and makes no claim about any jurisdiction's holidays.

## Boundary analysis

`boundary_report(year)` provides year and month starts/ends, weekday and ISO-week metadata, February length, leap status, and ISO week-year crossover details.

## Export

`calendar.export.markdown.month_grid(model)`, `calendar.export.csv.month_grid(model)`, and `calendar.export.json.encode(value)` produce deterministic strings. Markdown contains no promotional content. CSV quotes and doubles embedded quotes when required.

## CLI

The separate `betacalendars-cli` rock provides `betacal`:

```sh
luarocks install betacalendars-cli
betacal month 2027 1 --week-start monday --format markdown
betacal year 2027
betacal range 2026-12-20 2027-01-10
betacal boundaries 2027
```

## Fixtures

The package intentionally does not publish a separate fixtures rock. The date and boundary APIs can produce deterministic fixtures directly, without maintaining a redundant distribution.

## Compatibility

The implementation uses Lua 5.1 syntax and APIs, with no external runtime rocks. The supported and tested matrix is Lua 5.1 through 5.4 and LuaJIT.

## Testing

Run the dependency-free test suite from the repository root:

```sh
lua spec/run.lua
LUA_PATH="./src/?.lua;./src/?/init.lua;;" lua bin/betacal --help
```

The suite includes Gregorian boundary cases, ISO-week crossovers, date-range and recurrence checks, exporters, and month-grid invariants across a full 400-year Gregorian cycle.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Please include focused tests for changes to date arithmetic or recurrence semantics.

## Security

This library performs no network requests, telemetry, analytics, or automatic update checks. See [SECURITY.md](SECURITY.md).

## License

MIT. See [LICENSE](LICENSE).

## Project

Maintained by Beta Calendars: <https://www.betacalendars.com/>. Source and issue tracker: <https://github.com/mateopedersen/betacalendars-lua>.
