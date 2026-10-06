local date = require("betacalendars.date")
local M = {}
function M.boundary_report(year)
  assert(type(year) == "number" and year == math.floor(year) and year >= 1 and year <= 9999, "year must be an integer from 1 to 9999")
  local months, crossovers = {}, {}
  for month = 1, 12 do
    local first = { year = year, month = month, day = 1 }
    local last = { year = year, month = month, day = date.days_in_month(year, month) }
    local first_week, first_iso_year = date.iso_week(first)
    local last_week, last_iso_year = date.iso_week(last)
    months[month] = { month = month, start = first, end_date = last, start_weekday = date.weekday_name(first), end_weekday = date.weekday_name(last), iso_start_week = first_week, iso_start_year = first_iso_year, iso_end_week = last_week, iso_end_year = last_iso_year }
  end
  local start_date, end_date = { year = year, month = 1, day = 1 }, { year = year, month = 12, day = 31 }
  local start_week, start_iso_year = date.iso_week(start_date)
  local end_week, end_iso_year = date.iso_week(end_date)
  if start_iso_year ~= year then crossovers[#crossovers + 1] = { date = start_date, iso_week = start_week, iso_week_year = start_iso_year } end
  if end_iso_year ~= year then crossovers[#crossovers + 1] = { date = end_date, iso_week = end_week, iso_week_year = end_iso_year } end
  return { year = year, is_leap_year = date.is_leap_year(year), days_in_year = date.is_leap_year(year) and 366 or 365, start = start_date, end_date = end_date, start_weekday = date.weekday_name(start_date), end_weekday = date.weekday_name(end_date), february_days = date.days_in_month(year, 2), months = months, iso_week_year_crossovers = crossovers }
end
return M
