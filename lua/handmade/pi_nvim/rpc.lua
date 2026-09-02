local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Pi" })
end

local function read_source_line(filename, lnum)
  local ok, lines = pcall(vim.fn.readfile, filename, "", lnum)
  if not ok or type(lines) ~= "table" then
    return nil
  end
  return lines[lnum]
end

local function quickfix_height(count)
  return math.max(1, math.min(count, 16))
end

local function open_quickfix(count)
  local previous_win = vim.api.nvim_get_current_win()
  local opened = false

  local ok_quicker = pcall(require, "quicker")
  if ok_quicker then
    local ok = pcall(function()
      require("handmade.quickfix").open({ focus = false })
    end)
    opened = ok
  end

  if not opened then
    local ok = pcall(function()
      vim.cmd.copen({ count = quickfix_height(count) })
      require("handmade.quickfix").place_below(previous_win)
    end)
    opened = ok
  end

  if previous_win and vim.api.nvim_win_is_valid(previous_win) then
    pcall(vim.api.nvim_set_current_win, previous_win)
  end

  return opened
end

local function set_quickfix(payload)
  if type(payload.title) ~= "string" or payload.title == "" then
    error("set_quickfix requires a non-empty title")
  end
  if type(payload.items) ~= "table" then
    error("set_quickfix requires items")
  end

  local items = {}
  for i, item in ipairs(payload.items) do
    if type(item) ~= "table" then
      error("set_quickfix item " .. i .. " must be a table")
    end
    if type(item.filename) ~= "string" or item.filename == "" then
      error("set_quickfix item " .. i .. " requires filename")
    end
    if type(item.lnum) ~= "number" then
      error("set_quickfix item " .. i .. " requires lnum")
    end

    local qf_item = {
      filename = item.filename,
      lnum = item.lnum,
      col = item.col or 1,
      text = item.text,
    }

    if item.type ~= nil then
      qf_item.type = item.type
    end

    if qf_item.text == nil or qf_item.text == "" then
      qf_item.text = read_source_line(qf_item.filename, qf_item.lnum) or ""
    end

    table.insert(items, qf_item)
  end

  vim.fn.setqflist({}, "r", {
    title = payload.title,
    items = items,
  })

  local opened = false
  if payload.open ~= false then
    opened = open_quickfix(#items)
  end

  notify(string.format("Pi: quickfix set (%d item%s)", #items, #items == 1 and "" or "s"))

  return {
    ok = true,
    count = #items,
    opened = opened,
  }
end

local function register_client(payload)
  if type(payload.token) ~= "string" or payload.token == "" then
    error("register_client requires a launch token")
  end
  if type(payload.channel) ~= "number" then
    error("register_client requires a channel")
  end

  return require("handmade.pi_nvim.terminal").register_client(payload.token, payload.channel)
end

local function unregister_client(payload)
  return require("handmade.pi_nvim.terminal").unregister_client(payload.token, payload.channel)
end

function M.handle(payload)
  if type(payload) ~= "table" then
    error("pi_nvim rpc payload must be a table")
  end

  if payload.action == "set_quickfix" then
    return set_quickfix(payload)
  end
  if payload.action == "register_client" then
    return register_client(payload)
  end
  if payload.action == "unregister_client" then
    return unregister_client(payload)
  end
  if payload.action == "notify_error" then
    notify("Pi: " .. tostring(payload.message), vim.log.levels.ERROR)
    return { ok = true }
  end

  error("Unknown pi_nvim action: " .. tostring(payload.action))
end

return M
