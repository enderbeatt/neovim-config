return {

    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",

    config = function()
        require'nvim-treesitter.configs'.setup {
            ensure_installed = { "c", "cpp", "cmake", "python", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline"},

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,
            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            highlight = {
                enable = true,

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true
            },
            -- incremental_selection = {
            --     enable = true,
            --     keymaps = {
            --         init_selection = "<M-o>",
            --         scope_incremental = "<M-O>",
            --         node_incremental = "<M-o>",
            --         node_decremental = "<M-i>",
            --     },
            -- },
        }

        vim.treesitter.language.register('c', { 'vs', 'fs' })
    end
}
