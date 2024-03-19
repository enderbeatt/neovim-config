-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.6',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use {
        "VonHeikemen/lsp-zero.nvim",
        requires = {
            -- LSP
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lua' },

            { 'williamboman/mason-nvim-dap.nvim' },
            { 'jay-babu/mason-nvim-dap.nvim' },
            { 'mfussenegger/nvim-dap' },
            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' }
        }
    }
    use {
        "loctvl842/monokai-pro.nvim",
    }
    use{
        "stevearc/oil.nvim",
    }
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
    use('Civitasv/cmake-tools.nvim')
    use('kdheepak/lazygit.nvim')
    use {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        requires = { {"nvim-lua/plenary.nvim"} }
    }
end)
