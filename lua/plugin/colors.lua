return {
    {
        "EnDeRGeaT/onenord.nvim",
        -- dir = '~/projects/misc/onenord.nvim',
        lazy = false,
        priority = 1000,

        config = function()
            vim.cmd([[color onenord]])
        end
    }
}
