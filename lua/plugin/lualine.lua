return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        require('lualine').setup {
            sections = {
                lualine_x = { { require('handmade.timer').update_timer }, 'encoding', 'fileformat', 'filetype' }
            },
            disabled_filetypes = {
                winbar = {
                    "dap-view",
                    "dap-repl",
                    "dap-view-term",
                },
            },
        }
    end
}
