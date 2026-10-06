local date = require("betacalendars.date")
local M = {}
local short = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }
function M.month_grid(model)
  assert(type(model) == "table" and type(model.weeks) == "table", "month grid required")
  local headings, separator = {}, {}
  for column = 1, 7 do
    headings[column] = short[((date.weekday_index(model.week_start) + column - 2) % 7) + 1]
    separator[column] = "---"
  end
  local lines = { "| " .. table.concat(headings, " | ") .. " |", "| " .. table.concat(separator, " | ") .. " |" }
  for _, week in ipairs(model.weeks) do
    local cells = {}
    for column = 1, 7 do
      local cell = week[column]
      cells[column] = cell.empty and " " or (cell.in_month and tostring(cell.day) or "(" .. tostring(cell.day) .. ")")
    end
    lines[#lines + 1] = "| " .. table.concat(cells, " | ") .. " |"
  end
  return table.concat(lines, "\n")
end
return M
