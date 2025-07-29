local function get_vault_dir()
    if vim.uv.os_uname().sysname == "Linux" then
        return "~/obsidian-vault"
    else
        return "E:\\obsidian-vault"
    end
end

return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    config = function ()
        require('obsidian').setup({
            workspaces = {
                {
                    name = "vault",
                    path = get_vault_dir(),
                    overrides = {
                        notes_subdir = "000-Zettelkasten/not-linked",
                    },
                },
            },
            picker = {
                name = "snacks.pick",
            },
            completion = {
                blink = true,
            },
            templates = {
                folder = "999-Meta/templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
            },
        })
        vim.keymap.set("n", "<leader>oc", [[:Obsidian new_from_template<cr>]], { desc = "Create Obsidian Note From Template" })
        vim.keymap.set("n", "<leader>oo", [[:Obsidian open<cr>]],              { desc = "Open Obsidian" })
        vim.keymap.set("n", "<leader>os", [[:Obsidian search<cr>]],            { desc = "Search In Obsidian Vault" })
        vim.keymap.set("n", "<leader>ob", [[:Obsidian backlinks<cr>]],         { desc = "Look at backlinks" })
    end
}
