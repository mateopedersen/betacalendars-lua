local M = {}

local MONTHS = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
local WEEKDAYS = { "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday" }
local WEEKDAY_INDEX = {}
for i, name in ipairs(WEEKDAYS) do WEEKDAY_INDEX[name] = i end

function M.is_leap_year(year)
  assert(type(year) == "number" and year == math.floor(year) and year >= 1 and year <= 9999, "year must be an integer from 1 to 9999")
  return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function M.days_in_month(year, month)
  assert(type(month) == "number" and month == math.floor(month) and month >= 1 and month <= 12, "month must be an integer from 1 to 12")
  return month == 2 and M.is_leap_year(year) and 29 or MONTHS[month]
end

function M.validate(date)
  assert(type(date) == "table", "date must be a table")
  local y, m, d = date.year, date.month, date.day
  assert(type(y) == "number" and y == math.floor(y) and y >= 1 and y <= 9999, "year must be an integer from 1 to 9999")
  assert(type(m) == "number" and m == math.floor(m) and m >= 1 and m <= 12, "month must be an integer from 1 to 12")
  assert(type(d) == "number" and d == math.floor(d) and d >= 1 and d <= M.days_in_month(y, m), "day is outside the given month")
  return { year = y, month = m, day = d }
end

function M.ordinal(date)
  local d = M.validate(date)
  local y, total = d.year - 1, (d.year - 1) * 365
  total = total + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400)
  for month = 1, d.month - 1 do total = total + M.days_in_month(d.year, month) end
  return total + d.day - 1
end

function M.from_ordinal(ordinal)
  assert(type(ordinal) == "number" and ordinal == math.floor(ordinal) and ordinal >= 0 and ordinal <= M.ordinal({ year = 9999, month = 12, day = 31 }), "ordinal outside years 1..9999")
  local lo, hi = 1, 9999
  while lo < hi do
    local mid = math.floor((lo + hi + 1) / 2)
    if M.ordinal({ year = mid, month = 1, day = 1 }) <= ordinal then lo = mid else hi = mid - 1 end
  end
  local remain = ordinal - M.ordinal({ year = lo, month = 1, day = 1 })
  local month = 1
  while remain >= M.days_in_month(lo, month) do remain = remain - M.days_in_month(lo, month); month = month + 1 end
  return { year = lo, month = month, day = remain + 1 }
end

function M.add_days(date, amount)
  assert(type(amount) == "number" and amount == math.floor(amount), "amount must be an integer")
  return M.from_ordinal(M.ordinal(date) + amount)
end

function M.weekday(date)
  return (M.ordinal(date) % 7) + 1
end

function M.weekday_name(date)
  return WEEKDAYS[M.weekday(date)]
end

function M.weekday_index(value)
  assert(type(value) == "string" and WEEKDAY_INDEX[value:lower()], "weekday must be a name from monday through sunday")
  return WEEKDAY_INDEX[value:lower()]
end

function M.week_start_index(value)
  if value == nil then return 1 end
  if type(value) == "number" and value == math.floor(value) and value >= 1 and value <= 7 then return value end
  assert(type(value) == "string" and WEEKDAY_INDEX[value:lower()], "week_start must be a weekday name or integer 1..7")
  return WEEKDAY_INDEX[value:lower()]
end

function M.iso_week(date)
  local ordinal = M.ordinal(date)
  local weekday = (ordinal % 7) + 1
  local thursday = M.from_ordinal(ordinal + (4 - weekday))
  local jan4 = M.ordinal({ year = thursday.year, month = 1, day = 4 })
  local jan4_monday = jan4 - ((jan4 % 7))
  local week = math.floor((ordinal + (4 - weekday) - jan4_monday) / 7) + 1
  return week, thursday.year
end

function M.iso_date(date)
  local d = M.validate(date)
  return string.format("%04d-%02d-%02d", d.year, d.month, d.day)
end

function M.compare(a, b)
  local oa, ob = M.ordinal(a), M.ordinal(b)
  if oa < ob then return -1 elseif oa > ob then return 1 end
  return 0
end

M.weekdays = WEEKDAYS
return M
