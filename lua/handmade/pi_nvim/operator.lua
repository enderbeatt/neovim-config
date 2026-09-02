local M = {}

local namespace = vim.api.nvim_create_namespace("handmade_pi_nvim_operator")

local function notify_error(message)
  vim.notify(message, vim.log.levels.ERROR, { title = "Pi" })
end

local function clear_highlight(buf, mark)
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_del_extmark, buf, namespace, mark)
  end
end

local function source_path(buf)
  if vim.api.nvim_get_option_value("buftype", { buf = buf }) ~= "" then
    return nil, "Pi: ranges require a file-backed buffer"
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return nil, "Pi: ranges require a file-backed buffer"
  end

  if vim.api.nvim_get_option_value("modified", { buf = buf }) then
    return nil, "Pi: write the buffer before sending a range"
  end

  local path = vim.fn.fnamemodify(name, ":p")
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "file" then
    return nil, "Pi: ranges require a persisted file"
  end

  return path
end

local function send(buf, first_line, last_line)
  if first_line > last_line then
    first_line, last_line = last_line, first_line
  end

  local path, err = source_path(buf)
  if not path then
    notify_error(err)
    return
  end

  local line_count = vim.api.nvim_buf_line_count(buf)
  if first_line < 1 or last_line > line_count then
    notify_error("Pi: operator produced an invalid line range")
    return
  end

  local mark = vim.api.nvim_buf_set_extmark(buf, namespace, first_line - 1, 0, {
    end_row = last_line,
    end_col = 0,
    hl_group = "Visual",
    priority = 200,
  })

  local function finish()
    clear_highlight(buf, mark)
  end

  require("handmade.pi_nvim.terminal").send_range({
    path = path,
    start_line = first_line,
    end_line = last_line,
  }, {
    delivered = finish,
    failed = finish,
  })
end

function M.operatorfunc(_kind)
  local start_pos = vim.api.nvim_buf_get_mark(0, "[")
  local end_pos = vim.api.nvim_buf_get_mark(0, "]")
  send(vim.api.nvim_get_current_buf(), start_pos[1], end_pos[1])
end

function M.operator()
  vim.go.operatorfunc = "v:lua.pi_nvim_range_operator"
  return "g@"
end

function M.visual()
  local buf = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "x", false)
  send(buf, start_pos[2], end_pos[2])
end

function M.setup()
  _G.pi_nvim_range_operator = M.operatorfunc

  vim.keymap.set("n", "gp", function()
    return M.operator()
  end, { desc = "Add range to Pi", expr = true })

  vim.keymap.set("n", "gpp", function()
    return M.operator() .. "_"
  end, { desc = "Add line to Pi", expr = true })

  vim.keymap.set("x", "gp", M.visual, { desc = "Add range to Pi" })
end

return M
