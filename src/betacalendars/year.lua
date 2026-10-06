local grid = require("betacalendars.grid")
local M = {}
function M.year_grid(year, options)
  assert(type(year) == "number" and year == math.floor(year) and year >= 1 and year <= 9999, "year must be an integer from 1 to 9999")
  local months = {}
  for month = 1, 12 do months[month] = grid.month_grid(year, month, options) end
  return { year = year, months = months }
end
return M
