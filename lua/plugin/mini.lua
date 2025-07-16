return {

    "echasnovski/mini.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    version = false,

    config = function()
        local gen_spec = require('mini.ai').gen_spec.treesitter
        require("mini.ai").setup({
            custom_textobjects = {
                a = gen_spec({ a = '@parameter.outer', i = '@parameter.inner' }, { use_nvim_treesitter = true }),
                F = gen_spec({ a = '@function.outer', i = '@function.inner' }, { use_nvim_treesitter = true }),
            },
            n_lines = 500,
        })
        require('mini.surround').setup({
            mappings = {
                add = 'ys',
                delete = 'ds',
                find = '',
                find_left = '',
                highlight = '',
                replace = 'cs',
                update_n_lines = '',

                -- Add this only if you don't want to use extended mappings
                suffix_last = '',
                suffix_next = '',
            },
            search_method = 'cover_or_next',
        })

        require("mini.operators").setup({
            exchange = { prefix = "ge" }
        })
    end
}
