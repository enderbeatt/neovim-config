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
                a = gen_spec({ a = '@parameter.outer', i = '@parameter.inner' }),
            }

        })
        require("mini.surround").setup({})
        require("mini.operators").setup({
            exchange = { prefix = "ge" }
        })
    end
}
