local date = require("betacalendars.date")
local M = {}
local columns = { "date", "year", "month", "day", "weekday", "row", "column", "in_month" }
local function csv(value)
  local s = tostring(value)
  if s:find('[,"\r\n]') then return '"' .. s:gsub('"', '""') .. '"' end
  return s
end
M.escape = csv
function M.month_grid(model)
  assert(type(model) == "table" and type(model.cells) == "table", "month grid required")
  local lines = { table.concat(columns, ",") }
  for _, cell in ipairs(model.cells) do
    if not cell.empty then
      local row = { cell.iso_date, cell.year, cell.month, cell.day, cell.weekday, cell.row, cell.column, tostring(cell.in_month) }
      for i, value in ipairs(row) do row[i] = csv(value) end
      lines[#lines + 1] = table.concat(row, ",")
    end
  end
  return table.concat(lines, "\n")
end
return M
