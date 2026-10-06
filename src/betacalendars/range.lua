local date = require("betacalendars.date")
local M = {}
function M.date_range(from_date, to_date, options)
  options = options or {}
  local first, last = date.ordinal(from_date), date.ordinal(to_date)
  assert(last >= first, "to_date must not be before from_date")
  if options.exclusive_end then last = last - 1 end
  local count = math.max(0, last - first + 1)
  local limit = options.limit or 1000000
  assert(type(limit) == "number" and limit == math.floor(limit) and limit >= 0, "limit must be a non-negative integer")
  assert(count <= limit, "date range exceeds limit")
  local out = {}
  for n = first, last do out[#out + 1] = date.from_ordinal(n) end
  return out
end
return M
