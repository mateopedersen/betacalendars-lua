local date = require("betacalendars.date")
local M = {}

function M.month_grid(year, month, options)
  options = options or {}
  local first = { year = year, month = month, day = 1 }
  date.validate(first)
  local week_start = date.week_start_index(options.week_start)
  local fixed = options.fixed_rows ~= false
  local overflow = options.overflow ~= false
  local offset = (date.weekday(first) - week_start) % 7
  local needed = offset + date.days_in_month(year, month)
  local count = fixed and 42 or math.ceil(needed / 7) * 7
  local start = date.ordinal(first) - offset
  local cells, weeks = {}, {}
  for i = 0, count - 1 do
    local row, column = math.floor(i / 7) + 1, (i % 7) + 1
    local actual = date.from_ordinal(start + i)
    local in_month = actual.year == year and actual.month == month
    local cell
    if in_month or overflow then
      local iso_week, iso_week_year = date.iso_week(actual)
      cell = {
        year = actual.year, month = actual.month, day = actual.day,
        iso_date = date.iso_date(actual), weekday = date.weekday_name(actual),
        row = row, column = column, in_month = in_month,
        is_weekend = date.weekday(actual) >= 6,
        is_month_start = actual.day == 1,
        is_month_end = actual.day == date.days_in_month(actual.year, actual.month),
        is_year_start = actual.month == 1 and actual.day == 1,
        is_year_end = actual.month == 12 and actual.day == 31,
        iso_week = iso_week, iso_week_year = iso_week_year
      }
    else
      cell = { empty = true, row = row, column = column, weekday = date.weekdays[((week_start + column - 2) % 7) + 1], in_month = false }
    end
    cells[#cells + 1] = cell
  end
  for row = 1, count / 7 do
    local week = {}
    for column = 1, 7 do week[column] = cells[(row - 1) * 7 + column] end
    weeks[row] = week
  end
  return { year = year, month = month, week_start = date.weekdays[week_start], fixed_rows = fixed, overflow = overflow, rows = count / 7, cells = cells, weeks = weeks }
end

return M
