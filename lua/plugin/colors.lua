return {
    {
        "rmehri01/onenord.nvim",
        lazy = false,
        priority = 1000,

        config = function()
            vim.cmd([[color onenord]])
        end
    },
    {
        "loctvl842/monokai-pro.nvim",
        lazy = false,
        priority = 1000,
    },
}
