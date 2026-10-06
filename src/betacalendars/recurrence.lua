local date = require("betacalendars.date")
local M = {}

local function matches_nth(year, month, weekday, n)
  local first = { year = year, month = month, day = 1 }
  local day = 1 + ((weekday - date.weekday(first)) % 7) + (n - 1) * 7
  if day > date.days_in_month(year, month) then return nil end
  return { year = year, month = month, day = day }
end

local function monthly_candidate(rule, year, month)
  if rule.type == "monthly_day" then
    local day = rule.day
    assert(type(day) == "number" and day == math.floor(day) and day >= 1 and day <= 31, "day must be an integer from 1 to 31")
    local last = date.days_in_month(year, month)
    if day <= last then return { year = year, month = month, day = day } end
    local policy = rule.invalid_day or "skip"
    if policy == "skip" then return nil end
    if policy == "clamp" then return { year = year, month = month, day = last } end
    if policy == "error" then error(string.format("day %d does not exist in %04d-%02d", day, year, month)) end
    error("invalid_day must be 'skip', 'clamp', or 'error'")
  elseif rule.type == "nth_weekday" then
    local weekday = type(rule.weekday) == "string" and date.weekday_index(rule.weekday) or rule.weekday
    assert(type(weekday) == "number" and weekday >= 1 and weekday <= 7 and weekday == math.floor(weekday), "weekday must be a name or integer 1..7")
    local n = rule.n
    assert(type(n) == "number" and n == math.floor(n) and n >= 1 and n <= 5, "n must be 1..5")
    return matches_nth(year, month, weekday, n)
  elseif rule.type == "last_weekday" then
    local weekday = type(rule.weekday) == "string" and date.weekday_index(rule.weekday) or rule.weekday
    assert(type(weekday) == "number" and weekday >= 1 and weekday <= 7 and weekday == math.floor(weekday), "weekday must be a name or integer 1..7")
    local last = date.days_in_month(year, month)
    local d = { year = year, month = month, day = last }
    return { year = year, month = month, day = last - ((date.weekday(d) - weekday) % 7) }
  end
  error("unsupported recurrence type")
end

function M.expand(rule, from_date, to_date, options)
  assert(type(rule) == "table", "rule must be a table")
  options = options or {}
  local first, last = date.ordinal(from_date), date.ordinal(to_date)
  assert(last >= first, "to_date must not be before from_date")
  assert(last - first <= 3660000, "recurrence range exceeds 10000 years")
  local cap = options.limit or 10000
  assert(type(cap) == "number" and cap == math.floor(cap) and cap >= 0, "limit must be a non-negative integer")
  local out = {}
  local function add(candidate)
    if candidate then
      local ordinal = date.ordinal(candidate)
      if ordinal >= first and ordinal <= last then
        assert(#out < cap, "recurrence exceeds limit")
        out[#out + 1] = candidate
      end
    end
  end
  if rule.type == "weekly" then
    local weekday = type(rule.weekday) == "string" and date.weekday_index(rule.weekday) or rule.weekday
    assert(type(weekday) == "number" and weekday >= 1 and weekday <= 7 and weekday == math.floor(weekday), "weekday must be a name or integer 1..7")
    local ordinal = first + ((weekday - date.weekday(from_date)) % 7)
    while ordinal <= last do
      add(date.from_ordinal(ordinal))
      ordinal = ordinal + 7
    end
  elseif rule.type == "annual_date" then
    local month, day = rule.month, rule.day
    assert(type(month) == "number" and month == math.floor(month) and month >= 1 and month <= 12, "month must be 1..12")
    assert(type(day) == "number" and day == math.floor(day) and day >= 1 and day <= 31, "day must be 1..31")
    for year = from_date.year, to_date.year do add(monthly_candidate({ type = "monthly_day", day = day, invalid_day = rule.invalid_day }, year, month)) end
  elseif rule.type == "monthly_day" or rule.type == "nth_weekday" or rule.type == "last_weekday" then
    for year = from_date.year, to_date.year do
      local start_month = year == from_date.year and from_date.month or 1
      local end_month = year == to_date.year and to_date.month or 12
      for month = start_month, end_month do add(monthly_candidate(rule, year, month)) end
    end
  else
    error("type must be weekly, monthly_day, nth_weekday, last_weekday, or annual_date")
  end
  return out
end

return M
