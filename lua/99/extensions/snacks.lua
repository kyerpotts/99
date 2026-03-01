local pickers_util = require("99.extensions.pickers")

local M = {}

-- move the current value to the top of the list so Snacks opens with it focused
---@param list string[]
---@param current string
---@return string[]
local function promote_current(list, current)
  local out = { unpack(list) }
  for i, item in ipairs(out) do
    if item == current then
      table.remove(out, i)
      table.insert(out, 1, current)
      break
    end
  end
  return out
end

---@param provider _99.Providers.BaseProvider?
function M.select_model(provider)
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker or type(snacks.picker.select) ~= "function" then
    vim.notify(
      "99: snacks.nvim picker is required for this extension",
      vim.log.levels.ERROR
    )
    return
  end

  pickers_util.get_models(provider, function(models, current)
    snacks.picker.select(promote_current(models, current), {
      prompt = "99: Select Model (current: " .. current .. ")",
      format_item = function(item)
        return item
      end,
    }, function(selected)
      if not selected then
        return
      end
      pickers_util.on_model_selected(selected)
    end)
  end)
end

function M.select_provider()
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker or type(snacks.picker.select) ~= "function" then
    vim.notify(
      "99: snacks.nvim picker is required for this extension",
      vim.log.levels.ERROR
    )
    return
  end

  local info = pickers_util.get_providers()

  snacks.picker.select(promote_current(info.names, info.current), {
    prompt = "99: Select Provider (current: " .. info.current .. ")",
    format_item = function(item)
      return item
    end,
  }, function(selected)
    if not selected then
      return
    end
    pickers_util.on_provider_selected(selected, info.lookup)
  end)
end

return M
