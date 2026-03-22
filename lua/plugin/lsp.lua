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

            local lsp_configs = {
                clangd = {
                    capabilities = capabilities,
                    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
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
                        -- "--experimental-modules-support",
                        "--header-insertion=never",
                    },
                    root_markers = { 'compile_commands.json' },
                },
                rust_analyzer = {
                    capabilities = capabilities,
                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = true,
                        },
                    }
                },
                basedpyright = {
                    capabilities = capabilities,
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = "basic",
                            }
                        }
                    }
                },
                lua_ls = {
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            runtime = { version = "Lua 5.1" },
                            diagnostics = {
                                globals = { "vim", "it", "describe", "before_each", "after_each" },
                            }
                        }
                    },
                },
                zls = {
                    capabilities = capabilities,
                    cmd = { "zls" },
                    filetypes = { "zig", "zir" },
                    settings = {
                        enable_build_on_save = true,
                        build_on_save_step = "check",
                    },
                    root_markers = { "zls.json", "build.zig", ".git" },
                    single_file_support = true,
                }
            }
            for lsp, config in pairs(lsp_configs) do
                if not config.disabled then
                    vim.lsp.config(lsp, config)
                    vim.lsp.enable(lsp)
                end
            end

        end
    }
}
