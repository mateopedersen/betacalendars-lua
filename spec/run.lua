package.path = "./src/?.lua;./src/?/init.lua;" .. package.path
local b = require("betacalendars")
local date = require("betacalendars.date")
local checks = 0
local function eq(actual, expected, label)
  checks = checks + 1
  assert(actual == expected, (label or "value") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function truth(value, label) checks = checks + 1; assert(value, label or "expected true") end
local function raises(fn, label) checks = checks + 1; local ok = pcall(fn); assert(not ok, label or "expected an error") end

for year, expected in pairs({ [1900] = false, [2000] = true, [2024] = true, [2027] = false, [2028] = true, [2100] = false, [2400] = true }) do eq(b.is_leap_year(year), expected, "leap " .. year) end
eq(b.days_in_month(2000, 2), 29); eq(b.days_in_month(1900, 2), 28); raises(function() b.days_in_month(2024, 13) end)
eq(b.weekday_name({ year = 2024, month = 1, day = 1 }), "monday")
eq(b.iso_date(b.add_days({ year = 2026, month = 12, day = 31 }, 1)), "2027-01-01")
eq(b.iso_week({ year = 2021, month = 1, day = 1 }), 53); local _, iso_year = b.iso_week({ year = 2021, month = 1, day = 1 }); eq(iso_year, 2020)
raises(function() b.validate_date({ year = 2023, month = 2, day = 29 }) end)

local grid = b.month_grid(2027, 1, { week_start = "monday", fixed_rows = true, overflow = true })
eq(#grid.cells, 42); eq(grid.rows, 6); eq(grid.cells[1].iso_date, "2026-12-28")
local compact = b.month_grid(2027, 2, { week_start = "monday", fixed_rows = false, overflow = false })
eq(#compact.cells, 28); eq(compact.rows, 4); truth(compact.cells[1].in_month)
local blank_edges = b.month_grid(2027, 1, { week_start = "monday", fixed_rows = true, overflow = false })
truth(blank_edges.cells[1].empty)
local year = b.year_grid(2027, { week_start = "monday" }); eq(#year.months, 12); eq(year.months[12].month, 12)

for y = 1, 400 do
  for m = 1, 12 do
    local model = b.month_grid(y, m, { week_start = "monday", fixed_rows = true, overflow = true })
    eq(#model.cells, 42, "fixed count")
    local seen, in_month, previous = {}, 0, nil
    for i, cell in ipairs(model.cells) do
      eq(cell.row, math.floor((i - 1) / 7) + 1); eq(cell.column, ((i - 1) % 7) + 1)
      truth(not seen[cell.iso_date], "duplicate grid date"); seen[cell.iso_date] = true
      if cell.in_month then in_month = in_month + 1; eq(cell.year, y); eq(cell.month, m) end
      if previous then eq(date.ordinal({ year = cell.year, month = cell.month, day = cell.day }) - previous, 1, "consecutive grid") end
      previous = date.ordinal({ year = cell.year, month = cell.month, day = cell.day })
    end
    eq(in_month, date.days_in_month(y, m), "month date count")
  end
end

local range = b.date_range({ year = 2026, month = 12, day = 30 }, { year = 2027, month = 1, day = 2 })
eq(#range, 4); eq(date.iso_date(range[4]), "2027-01-02")
eq(#b.date_range({ year = 2027, month = 1, day = 1 }, { year = 2027, month = 1, day = 2 }, { exclusive_end = true }), 1)
local weekly = b.expand_recurrence({ type = "weekly", weekday = "wednesday" }, { year = 2027, month = 1, day = 1 }, { year = 2027, month = 1, day = 31 })
truth(#weekly >= 4 and #weekly <= 5)
local first_monday = b.expand_recurrence({ type = "nth_weekday", n = 1, weekday = "monday" }, { year = 2027, month = 1, day = 1 }, { year = 2027, month = 3, day = 31 })
eq(#first_monday, 3); eq(first_monday[1].day, 4)
local last_friday = b.expand_recurrence({ type = "last_weekday", weekday = "friday" }, { year = 2027, month = 1, day = 1 }, { year = 2027, month = 1, day = 31 })
eq(last_friday[1].day, 29)
local clamp = b.expand_recurrence({ type = "monthly_day", day = 31, invalid_day = "clamp" }, { year = 2027, month = 2, day = 1 }, { year = 2027, month = 2, day = 28 })
eq(clamp[1].day, 28)
raises(function() b.expand_recurrence({ type = "monthly_day", day = 31, invalid_day = "error" }, { year = 2027, month = 2, day = 1 }, { year = 2027, month = 2, day = 28 }) end)
eq(#b.expand_recurrence({ type = "annual_date", month = 1, day = 15 }, { year = 2024, month = 1, day = 1 }, { year = 2028, month = 12, day = 31 }), 5)
raises(function() b.expand_recurrence({ type = "weekly", weekday = 1 }, { year = 2027, month = 1, day = 1 }, { year = 2027, month = 12, day = 31 }, { limit = 2 }) end)

truth(b.is_weekend({ year = 2027, month = 1, day = 2 })); truth(not b.is_business_day({ year = 2027, month = 1, day = 2 }))
truth(not b.is_business_day({ year = 2027, month = 1, day = 4 }, { excluded_dates = { ["2027-01-04"] = true } }))
eq(b.business_days_between({ year = 2027, month = 1, day = 4 }, { year = 2027, month = 1, day = 8 }), 5)
eq(date.weekday_name(b.next_business_day({ year = 2027, month = 1, day = 1 })), "monday")
eq(b.boundary_report(2024).february_days, 29); eq(b.boundary_report(2024).days_in_year, 366)

local md = b.export.markdown.month_grid(grid); truth(md:find("| Mon | Tue | Wed", 1, true) ~= nil); truth(not md:find("https://", 1, true))
local csv = b.export.csv.month_grid(grid); truth(csv:find("date,year,month,day", 1, true) ~= nil)
eq(b.export.csv.escape('a,"b"'), '"a,""b"""'); eq(b.export.csv.escape("a\nb"), '"a\nb"')
local encoded = b.export.json.encode({ z = 1, a = { true, false } }); eq(encoded, '{"a":[true,false],"z":1}')
eq(b.export.json.encode(grid), b.export.json.encode(grid), "stable JSON")

print("OK - " .. checks .. " assertions")
