return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        require('lualine').setup {
            sections = {
                lualine_x = { { require('handmade.timer').update_timer }, 'encoding', 'fileformat', 'filetype' }

            }
        }
    end
}
