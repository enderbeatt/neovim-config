local function get_vault_dir()
    if vim.uv.os_uname().sysname == "Linux" then
        return "~/obsidian-vault"
    else
        return "E:\\obsidian-vault"
    end
end

local function get_refile()
    if vim.uv.os_uname().sysname == "Linux" then
        return "~/obsidian-vault/refile.md"
    else
        return "E:\\obsidian-vault\\refile.md"
    end
end

local function open_refile()
    local buf = vim.api.nvim_create_buf(false, false)

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    local opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_set_current_win(win)

    local file = vim.fn.expand(get_refile())
    vim.cmd("edit " .. file)
    vim.cmd("norm G")
    vim.cmd("Obsidian template task")
end

local function refile()
    local filename = vim.api.nvim_buf_get_name(0)
    if filename ~= get_refile() then
        vim.notify("You are not inside a refile.md", vim.log.levels.ERROR)
        return
    end
    local types = {
        n = '000-Zettelkasten/not-linked/',
        t = '005-Tasks/',
    }
    local type = vim.fn.input("Enter type ([t]ask, [n]ote): ")
    local ty = types[type]
    if ty == nil then
        vim.notify("Wrong type", vim.log.levels.ERROR)
        return
    end
    local filename = vim.fn.input("Enter file name (without .md): ")
    vim.cmd("Obsidian extract_note " .. get_vault_dir() .. '/' .. ty .. filename)
end

local function agenda()
    vim.cmd("Obsidian tags task/next task/todo")
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
        vim.keymap.set("n", "<leader>oo", [[:Obsidian open<cr>]],              { desc = "Open Obsidian" })
        vim.keymap.set("n", "<leader>os", [[:Obsidian search<cr>]],            { desc = "Search In Obsidian Vault" })
        vim.keymap.set("n", "<leader>ob", [[:Obsidian backlinks<cr>]],         { desc = "Look at backlinks" })
        vim.keymap.set("n", "<leader>ot", [[:Obsidian tags<cr>]],              { desc = "Search through tags" })
        vim.keymap.set("n", "<leader>oi", open_refile,                         { desc = "Add a new note to refile" })
        vim.keymap.set("v", "<leader>or", refile,                              { desc = "Refile the note"})
        vim.keymap.set("n", "<leader>oa", agenda,                              { desc = "Get agenda" })
    end
}
