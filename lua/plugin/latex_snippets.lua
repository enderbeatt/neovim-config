return {

    "iurimateus/luasnip-latex-snippets.nvim",
    dependencies = { 'L3MON4D3/LuaSnip' },

    config = function()
        require'luasnip-latex-snippets'.setup({
            use_treesitter = true, -- whether to use treesitter to determine if cursor is in math mode; if false, vimtex is used
            allow_on_markdown = true, -- whether to add snippets to markdown filetype
        })
        require("luasnip").config.setup({ enable_autosnippets = true })
    end
}
