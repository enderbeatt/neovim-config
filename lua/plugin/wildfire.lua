return {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        surrounds = {
            { "(", ")" },
            { "{", "}" },
            { "<", ">" },
            { "[", "]" },
        },
        keymaps = {
            init_selection = "<M-o>",
            node_incremental = "<M-o>",
            node_decremental = "<M-i>",
        },
        filetype_exclude = { "qf" }, --keymaps will be unset in excluding filetypes
    },
}
