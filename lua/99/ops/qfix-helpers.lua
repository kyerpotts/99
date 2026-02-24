local M = {}

--- @return _99.Search.Result | nil
function M.parse_line(line)
  local parts = vim.split(line, ":", { plain = true })
  if #parts ~= 3 then
    return nil
  end

  local filepath = parts[1]
  local lnum = parts[2]
  local comma_parts = vim.split(parts[3], ",", { plain = true })
  local col = comma_parts[1]
  local notes = nil

  if #comma_parts >= 2 then
    notes = table.concat(comma_parts, ",", 2)
  end

  return {
    filename = filepath,
    lnum = tonumber(lnum) or 1,
    col = tonumber(col) or 1,
    text = notes or "",
  }
end

--- @param response string
--- @return _99.Search.Result[]
function M.create_qfix_entries(response)
  local lines = vim.split(response, "\n")
  local qf_list = {} --[[ @as _99.Search.Result[] ]]

  for _, line in ipairs(lines) do
    local res = M.parse_line(line)
    if res then
      table.insert(qf_list, res)
    end
  end
  return qf_list
end

return M
