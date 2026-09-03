local M = {}

local function add_lines(first_line, last_line)
  if first_line > last_line then
    first_line, last_line = last_line, first_line
  end

  require("opencode.api").add_visual_selection({ open_input = false }, {
    start = first_line,
    stop = last_line,
  })
end

function M.operatorfunc(_kind)
  local start_pos = vim.api.nvim_buf_get_mark(0, "[")
  local end_pos = vim.api.nvim_buf_get_mark(0, "]")
  add_lines(start_pos[1], end_pos[1])
end

function M.operator()
  vim.go.operatorfunc = "v:lua.opencode_range_operator"
  return "g@"
end

function M.visual()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "x", false)
  add_lines(start_pos[2], end_pos[2])
end

function M.setup()
  _G.opencode_range_operator = M.operatorfunc

  vim.keymap.set("n", "go", function()
    return M.operator()
  end, { desc = "Add range to Opencode", expr = true })

  vim.keymap.set("n", "goo", function()
    return M.operator() .. "_"
  end, { desc = "Add line to Opencode", expr = true })

  vim.keymap.set("x", "go", M.visual, { desc = "Add range to Opencode" })
end

return M
