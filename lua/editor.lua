vim.opt.compatible = false

vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.opt.smartindent = true


vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wrap = false

vim.opt.conceallevel = 2

vim.opt.signcolumn = "yes"

vim.opt.timeoutlen = 200

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("n", "]q", [[:cn<cr>]])
vim.keymap.set("n", "[q", [[:cp<cr>]])
vim.keymap.set("t", "<esc><esc>", [[<c-\><c-n>]])

vim.keymap.set("n", "<leader>1", [[1gt]])
vim.keymap.set("n", "<leader>2", [[2gt]])
vim.keymap.set("n", "<leader>3", [[3gt]])
vim.keymap.set("n", "<leader>4", [[4gt]])

vim.cmd([[autocmd BufEnter *.slint :setlocal filetype=slint]])

vim.keymap.set({"n", "t"}, "<C-t>", function ()
    vim.cmd[[cclose]]
    require('handmade.terminal').toggle_terminal()
end, {silent = true, desc = "Toggle Terminal"})


