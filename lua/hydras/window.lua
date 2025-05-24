local hydra = require('hydra')

hydra({
    name = "WINDOW",
    mode = "n",
    body = "<C-W>",
    heads = {
        { 'h', '<C-w>h' },
        { 'j', '<C-w>j' },
        { 'k', '<C-w>k' },
        { 'l', '<C-w>l' },
        -- { 's', '<C-w>s' },
        -- { 'v', '<C-w>v' },
        { '+', '<C-w>+' },
        { '-', '<C-w>-' },
        { '>', '<C-w>>' },
        { '<', '<C-w><' },
        -- { '=', '<C-w>=' },
        -- { 'q', '<cmd>close<CR>' },
        -- { 'o', '<cmd>only<CR>' },
        -- { '_', '<C-w>_' },
        -- { '|', '<C-w>|' },
        { '<Esc>', nil,  { exit = true, desc = false } },
    },
})
