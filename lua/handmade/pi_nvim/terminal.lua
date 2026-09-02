local M = {}

local state = {
  bufnr = nil,
  winid = nil,
  job_id = nil,
  pid = nil,
  token = nil,
  rpc_chan = nil,
  pending = {},
  pending_timer = nil,
  closing = false,
}

local delivery_timeout_ms = 10000

local function default_win_opts()
  return {
    split = "right",
    width = math.floor(vim.o.columns * 0.35),
  }
end

local function terminate(pid)
  if not pid then
    return
  end

  if vim.fn.has("unix") == 1 then
    os.execute("kill -TERM -" .. tostring(pid) .. " 2>/dev/null")
  else
    pcall(vim.uv.kill, pid, "SIGTERM")
  end
end

local function cleanup_process()
  if state.job_id then
    pcall(vim.fn.jobstop, state.job_id)
  end
  if state.pid then
    terminate(state.pid)
  end
  state.job_id = nil
  state.pid = nil
end

local function stop_pending_timer()
  local timer = state.pending_timer
  state.pending_timer = nil
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

local function fail_pending(message)
  if #state.pending == 0 then
    stop_pending_timer()
    return
  end

  local pending = state.pending
  state.pending = {}
  stop_pending_timer()

  for _, item in ipairs(pending) do
    if item.failed then
      pcall(item.failed)
    end
  end

  vim.notify(message, vim.log.levels.ERROR, { title = "Pi" })
end

local function channel_is_valid(chan)
  if not chan then
    return false
  end

  local ok, info = pcall(vim.api.nvim_get_chan_info, chan)
  return ok and type(info) == "table" and info.id == chan and info.mode == "rpc"
end

local function deliver(item)
  if not channel_is_valid(state.rpc_chan) then
    state.rpc_chan = nil
    return false
  end

  local ok, result = pcall(vim.rpcnotify, state.rpc_chan, "pi_nvim_append_range", item.payload)
  if not ok or result == 0 then
    state.rpc_chan = nil
    return false
  end

  if item.delivered then
    pcall(item.delivered)
  end
  return true
end

local function start_pending_timer()
  if state.pending_timer then
    return
  end

  state.pending_timer = vim.defer_fn(function()
    state.pending_timer = nil
    fail_pending("Pi: timed out waiting for the managed RPC connection")
  end, delivery_timeout_ms)
end

local function flush_pending()
  local first_unsent
  for index, item in ipairs(state.pending) do
    if not deliver(item) then
      first_unsent = index
      break
    end
  end

  if first_unsent then
    state.pending = vim.list_slice(state.pending, first_unsent)
    start_pending_timer()
  else
    state.pending = {}
    stop_pending_timer()
  end
end

local function clear_state_for_buf(buf)
  if state.bufnr == buf then
    state.bufnr = nil
    state.winid = nil
    state.job_id = nil
    state.pid = nil
    state.token = nil
    state.rpc_chan = nil
  end
end

local function setup_autocmds(buf)
  local group = vim.api.nvim_create_augroup("handmade_pi_nvim_terminal_" .. tostring(buf), { clear = true })

  vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    buffer = buf,
    once = true,
    callback = function(event)
      state.job_id = vim.b[event.buf].terminal_job_id
      local ok, pid = pcall(vim.fn.jobpid, state.job_id)
      if ok then
        state.pid = pid
      end
    end,
  })

  vim.api.nvim_create_autocmd("TermClose", {
    group = group,
    buffer = buf,
    once = true,
    callback = function()
      cleanup_process()
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    once = true,
    callback = function()
      if not state.closing then
        cleanup_process()
        fail_pending("Pi: managed session closed before ranges were delivered")
      end
      clear_state_for_buf(buf)
    end,
  })

  vim.api.nvim_create_autocmd("ExitPre", {
    group = group,
    once = true,
    callback = function()
      cleanup_process()
    end,
  })
end

local function open_window(buf)
  local previous_win = vim.api.nvim_get_current_win()
  state.winid = vim.api.nvim_open_win(buf, true, default_win_opts())
  if previous_win and vim.api.nvim_win_is_valid(previous_win) then
    vim.api.nvim_set_current_win(previous_win)
  end
end

function M.open(args)
  if state.bufnr ~= nil and vim.api.nvim_buf_is_valid(state.bufnr) then
    if state.winid == nil or not vim.api.nvim_win_is_valid(state.winid) then
      open_window(state.bufnr)
    end
    return true
  end

  local previous_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, false)
  state.bufnr = buf
  state.token = vim.fn.sha256(vim.fn.tempname() .. tostring(vim.uv.hrtime()))
  state.rpc_chan = nil
  state.winid = vim.api.nvim_open_win(buf, true, default_win_opts())
  vim.api.nvim_buf_set_name(buf, "pi://terminal")
  setup_autocmds(buf)

  local cmd = "pi"
  if args and args ~= "" then
    cmd = cmd .. " " .. args
  end

  state.job_id = vim.fn.jobstart(cmd, {
    term = true,
    env = {
      PI_NVIM_LAUNCH_TOKEN = state.token,
    },
    on_exit = function()
      M.close()
    end,
  })

  if previous_win and vim.api.nvim_win_is_valid(previous_win) then
    vim.api.nvim_set_current_win(previous_win)
  end

  if state.job_id <= 0 then
    vim.notify("Pi: failed to start the managed terminal", vim.log.levels.ERROR, { title = "Pi" })
    M.close()
    return false
  end

  return true
end

function M.toggle(args)
  if state.winid ~= nil and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_win_hide(state.winid)
    state.winid = nil
    return
  end

  if state.bufnr ~= nil and vim.api.nvim_buf_is_valid(state.bufnr) then
    open_window(state.bufnr)
    return
  end

  M.open(args)
end

function M.close()
  if state.closing then
    return
  end
  state.closing = true

  fail_pending("Pi: managed session closed before ranges were delivered")
  cleanup_process()

  if state.winid ~= nil and vim.api.nvim_win_is_valid(state.winid) then
    pcall(vim.api.nvim_win_close, state.winid, true)
  end

  local buf = state.bufnr
  if buf ~= nil and vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end

  state.bufnr = nil
  state.winid = nil
  state.job_id = nil
  state.pid = nil
  state.token = nil
  state.rpc_chan = nil
  state.closing = false
end

function M.register_client(token, channel)
  if type(token) ~= "string" or token == "" or token ~= state.token then
    return { ok = false, reason = "launch token does not match the managed Pi session" }
  end
  if type(channel) ~= "number" or not channel_is_valid(channel) then
    return { ok = false, reason = "RPC channel is invalid" }
  end

  state.rpc_chan = channel
  flush_pending()
  return { ok = true }
end

function M.unregister_client(token, channel)
  if token == state.token and (channel == nil or channel == state.rpc_chan) then
    state.rpc_chan = nil
  end
  return { ok = true }
end

function M.send_range(payload, callbacks)
  callbacks = callbacks or {}

  if state.bufnr == nil or not vim.api.nvim_buf_is_valid(state.bufnr) then
    if not M.open() then
      if callbacks.failed then
        pcall(callbacks.failed)
      end
      return false
    end
  end

  local item = {
    payload = vim.tbl_extend("force", payload, { token = state.token }),
    delivered = callbacks.delivered,
    failed = callbacks.failed,
  }

  if deliver(item) then
    return true
  end

  table.insert(state.pending, item)
  start_pending_timer()
  return true
end

function M.is_open()
  return state.winid ~= nil and vim.api.nvim_win_is_valid(state.winid)
end

return M
