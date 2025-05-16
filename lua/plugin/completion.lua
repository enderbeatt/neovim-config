return {
    {
        'saghen/blink.cmp',
        dependencies = { 'L3MON4D3/LuaSnip' },

        version = '1.1.1',

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = { preset = 'enter' },

            enabled = function ()
                if require('handmade.debug_helpers').is_dap_window(vim.bo.filetype) then
                    return false
                end
                return true
            end,

            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 100 },
                menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind_icon", gap = 1, "kind" } } } }
            },
            snippets = { preset = "luasnip" },
            appearance = {
                use_nvim_cmp_as_default = true,
            },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },
                },
            },

            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" }
    }
}
