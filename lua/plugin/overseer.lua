return {
  'stevearc/overseer.nvim',
  opts = {},
  config = function ()
      require('overseer').setup({
          component_aliases = {
              -- Most tasks are initialized with the default components
              default = {
                  { "display_duration", detail_level = 2 },
                  "on_output_summarize",
                  "on_exit_set_status",
                  "on_complete_notify",
                  { "on_output_quickfix", open = true},
                  { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
              },
              -- Tasks from tasks.json use these components
              default_vscode = {
                  "default",
                  "on_result_diagnostics",
              },
          },
      })
      vim.keymap.set('n', '<leader>tt', [[:OverseerToggle<cr>]], {desc = '[T]ask [T]oggle'})
      vim.keymap.set('n', '<leader>tn', [[:OverseerBuild<cr>]], {desc = '[T]ask [N]ew'})
      vim.keymap.set('n', '<leader>tr', [[:OverseerQuickAction restart<cr>]], {desc = '[T]ask [R]un Last'});
  end
}
