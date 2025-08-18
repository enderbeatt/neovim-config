return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require('mason').setup()
        end
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "L3MON4D3/LuaSnip",
            "saghen/blink.cmp"
        },
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP actions',
                callback = function(event)
                    vim.b[event.buf].show_signs = false
                    local opts = {buffer = event.buf}

                    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition({on_list = function (options)
                        vim.fn.setqflist({}, ' ', options)
                        vim.cmd[[silent cfirst]]
                    end}) end, opts)
                    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                    vim.keymap.set("n", "<leader>e", function() vim.diagnostic.open_float() end, opts)
                    vim.keymap.set({ "n", "x" }, "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
                    vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
                    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
                    vim.keymap.set({ "n", "v" }, "<leader>rf", function() vim.lsp.buf.format() end, opts)
                end
            })

            local capabilities = require('blink.cmp').get_lsp_capabilities()

            require('mason').setup({})

            vim.diagnostic.config({virtual_text = true})

            vim.api.nvim_create_autocmd("LspProgress", {
                callback = function(ev)
                    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
                    Snacks.notifier(vim.lsp.status(), "info", {
                        id = "lsp_progress",
                        title = "LSP Progress",
                        opts = function(notif)
                            notif.icon = ev.data.params.value.kind == "end" and " "
                            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                        end,
                    })
                end,
            })

            require('lspconfig').clangd.setup({
                capabilities = capabilities,
                cmd = {
                    "clangd",
                    "--background-index",
                    "-j=8",
                    -- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
                    -- to add more checks, create .clang-tidy file in the root directory
                    -- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
                    "--clang-tidy",
                    "--completion-style=bundled",
                    "--cross-file-rename",
                    "--experimental-modules-support",
                    "--header-insertion=never",
                },
                root_markers = { 'compile_commands.json' },
            })
            require('lspconfig').rust_analyzer.setup({
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = true,
                    },
                }
            })
            require('lspconfig').basedpyright.setup({
                capabilities = capabilities,
                settings = {
                    basedpyright = {
                        analysis = {
                            typeCheckingMode = "basic",
                        }
                    }
                }
            })
            require('lspconfig').lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = "Lua 5.1" },
                        diagnostics = {
                            globals = { "vim", "it", "describe", "before_each", "after_each" },
                        }
                    }
                }
            })

        end
    }
}
