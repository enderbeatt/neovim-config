return {
    {
        "EnDeRGeaT/onenord.nvim",
        lazy = false,
        priority = 1000,

        -- config = function()
        --     vim.cmd([[color onenord]])
        -- end
    },
    {
        "sainnhe/gruvbox-material",
        lazy = false,
        priority = 1000,

        config = function()
            vim.g.gruvbox_material_background = 'soft'
            vim.g.gruvbox_material_foreground = 'mix'
            vim.g.gruvbox_material_better_performance = 1
            vim.g.gruvbox_material_disable_italic_comment = 1
            vim.g.gruvbox_material_diagnostic_virtual_text = 'colored';
            vim.cmd([[set termguicolors]])
            vim.cmd([[color gruvbox-material]])
        end
    },
    -- {
    --     "loctvl842/monokai-pro.nvim",
    --     lazy = false,
    --     priority = 1000,
    --
    --     config = function()
    --         vim.cmd([[color monokai-pro-ristretto]])
    --     end
    -- },
}
