local date = require("betacalendars.date")
local M = {}
local function config(options)
  options = options or {}
  local weekend = {}
  local days = options.weekend or { 6, 7 }
  for _, value in ipairs(days) do
    local index = type(value) == "string" and date.weekday_index(value) or value
    assert(type(index) == "number" and index >= 1 and index <= 7 and index == math.floor(index), "weekend values must be weekday names or 1..7")
    weekend[index] = true
  end
  local excluded = {}
  for key, value in pairs(options.excluded_dates or {}) do
    if type(key) == "string" and value then excluded[key] = true
    elseif type(value) == "table" then excluded[date.iso_date(value)] = true end
  end
  return weekend, excluded
end
function M.is_weekend(value, options)
  local weekend = config(options)
  return weekend[date.weekday(value)] == true
end
function M.is_business_day(value, options)
  local weekend, excluded = config(options)
  return not weekend[date.weekday(value)] and not excluded[date.iso_date(value)]
end
function M.business_days_between(from_date, to_date, options)
  local first, last = date.ordinal(from_date), date.ordinal(to_date)
  assert(last >= first, "to_date must not be before from_date")
  assert(last - first <= 3660000, "range exceeds 10000 years")
  local count = 0
  for ordinal = first, last do if M.is_business_day(date.from_ordinal(ordinal), options) then count = count + 1 end end
  return count
end
local function shift(value, step, options)
  local ordinal = date.ordinal(value)
  for _ = 1, 14 do
    ordinal = ordinal + step
    local candidate = date.from_ordinal(ordinal)
    if M.is_business_day(candidate, options) then return candidate end
  end
  error("could not find a business day within 14 days")
end
function M.next_business_day(value, options) return shift(value, 1, options) end
function M.previous_business_day(value, options) return shift(value, -1, options) end
return M
