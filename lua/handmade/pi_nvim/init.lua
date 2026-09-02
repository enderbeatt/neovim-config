local M = {}

function M.toggle(args)
  require("handmade.pi_nvim.terminal").toggle(args)
end

function M.close()
  require("handmade.pi_nvim.terminal").close()
end

local function debug_quickfix()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == "" then
    vim.notify("Pi: current buffer has no file name", vim.log.levels.ERROR, { title = "Pi" })
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1]

  local ok, result = pcall(require("handmade.pi_nvim.rpc").handle, {
    action = "set_quickfix",
    title = "Pi debug quickfix",
    items = {
      {
        filename = filename,
        lnum = lnum,
        col = 1,
        text = "Pi debug item at current line",
      },
    },
    open = true,
  })

  if not ok then
    vim.notify("Pi debug quickfix failed: " .. tostring(result), vim.log.levels.ERROR, { title = "Pi" })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("PiToggle", function(opts)
    M.toggle(opts.args)
  end, {
    nargs = "*",
    desc = "Toggle Pi terminal",
  })

  vim.api.nvim_create_user_command("PiClose", function()
    M.close()
  end, {
    desc = "Close Pi terminal",
  })

  vim.api.nvim_create_user_command("PiDebugQuickfix", debug_quickfix, {
    desc = "Populate a sample Pi quickfix list",
  })

  vim.keymap.set("n", "<leader>pt", function()
    M.toggle()
  end, { desc = "Toggle Pi" })

  require("handmade.pi_nvim.operator").setup()
end

return M
