return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "dlyongemallo/diffview.nvim",
        "lewis6991/gitsigns.nvim",

        "folke/snacks.nvim",
    },
    config = function ()
        vim.keymap.set('n', '<leader>lg', require("neogit").open)
        require('gitsigns').setup{
            signcolumn = false,
            on_attach = function(bufnr)
                local gitsigns = require('gitsigns')

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({']c', bang = true})
                    else
                        gitsigns.nav_hunk('next')
                    end
                end)

                map('n', '[c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({'[c', bang = true})
                    else
                        gitsigns.nav_hunk('prev')
                    end
                end)

                -- Actions
                map('n', '<leader>hs', gitsigns.stage_hunk)
                map('n', '<leader>hr', gitsigns.reset_hunk)

                map('v', '<leader>hs', function()
                    gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end)

                map('v', '<leader>hr', function()
                    gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end)

                map('n', '<leader>hS', gitsigns.stage_buffer)
                map('n', '<leader>hR', gitsigns.reset_buffer)
                map('n', '<leader>hp', gitsigns.preview_hunk)
                map('n', '<leader>hi', gitsigns.preview_hunk_inline)

                map('n', '<leader>hb', function()
                    gitsigns.blame_line({ full = true })
                end)

                map('n', '<leader>hd', gitsigns.diffthis)

                map('n', '<leader>hD', function()
                    gitsigns.diffthis('~')
                end)

                map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
                map('n', '<leader>hq', gitsigns.setqflist)

                -- Toggles
                map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
                map('n', '<leader>tw', gitsigns.toggle_word_diff)

                -- Text object
                map({'o', 'x'}, 'ih', gitsigns.select_hunk)
            end
        }

        vim.api.nvim_create_user_command("ChangeSignsBase", function()
            local gitsigns = require("gitsigns")
            local current_base = require("gitsigns.config").config.base
            local current_commit
            local root = Snacks.git.get_root()

            if current_base and root then
                local result = vim.system({
                    "git", "-C", root, "rev-parse", "--verify",
                    current_base .. "^{commit}",
                }, { text = true }):wait()
                if result.code == 0 then
                    current_commit = vim.trim(result.stdout)
                end
            end

            local function position_at_current_base(picker)
                local function position()
                    if picker.closed then
                        return
                    end
                    if picker:is_active() then
                        vim.defer_fn(position, 20)
                        return
                    end

                    for item, index in picker:iter() do
                        local is_current = current_commit
                            and item.commit
                            and current_commit:sub(1, #item.commit) == item.commit
                        if is_current or (current_base == nil and item.signs_base == "index") then
                            picker.list:set_target(index, nil, { force = true })
                            picker.list:update({ force = true })
                            return
                        end
                    end
                end

                position()
            end

            Snacks.picker.git_log({
                title = "Gitsigns base commit",
                format = function(item, picker)
                    if item.signs_base == "index" then
                        return { { "Index (default)", "Comment" } }
                    end
                    return Snacks.picker.format.git_log(item, picker)
                end,
                preview = function(ctx)
                    if ctx.item.signs_base == "index" then
                        ctx.preview:notify("Git index", "info", { item = false })
                    else
                        Snacks.picker.preview.git_show(ctx)
                    end
                end,
                on_show = function(picker)
                    if current_base == nil then
                        picker.list:add({
                            text = "Index (default)",
                            commit = "HEAD",
                            signs_base = "index",
                        }, false)
                        picker.list:update({ force = true })
                    end
                    position_at_current_base(picker)
                end,
                confirm = function(picker, item)
                    picker:close()
                    if item then
                        if item.signs_base == "index" then
                            gitsigns.change_base(nil, true)
                        else
                            gitsigns.change_base(item.commit, true)
                        end
                    end
                end,
            })
        end, { force = true })
    end
}
