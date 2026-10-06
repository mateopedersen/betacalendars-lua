local M = {}
local function quote(s)
  return '"' .. s:gsub('[%z\1-\31\\"]', function(c)
    local map = { ['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }
    return map[c] or string.format("\\u%04x", string.byte(c))
  end) .. '"'
end
local function encode(value, stack)
  local kind = type(value)
  if value == nil then return "null" end
  if kind == "boolean" then return value and "true" or "false" end
  if kind == "number" then assert(value == value and value ~= math.huge and value ~= -math.huge, "JSON numbers must be finite"); return tostring(value) end
  if kind == "string" then return quote(value) end
  assert(kind == "table", "unsupported JSON value type: " .. kind)
  assert(not stack[value], "cannot encode a cyclic table")
  stack[value] = true
  local n, array = #value, true
  for k in pairs(value) do if type(k) ~= "number" or k < 1 or k > n or k ~= math.floor(k) then array = false; break end end
  local parts = {}
  if array then
    for i = 1, n do parts[i] = encode(value[i], stack) end
    stack[value] = nil
    return "[" .. table.concat(parts, ",") .. "]"
  end
  local keys = {}
  for k in pairs(value) do assert(type(k) == "string", "JSON object keys must be strings"); keys[#keys + 1] = k end
  table.sort(keys)
  for i, key in ipairs(keys) do parts[i] = quote(key) .. ":" .. encode(value[key], stack) end
  stack[value] = nil
  return "{" .. table.concat(parts, ",") .. "}"
end
function M.encode(value) return encode(value, {}) end
return M
