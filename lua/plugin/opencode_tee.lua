return {
  "sudo-tee/opencode.nvim",
  opts = {
    default_global_keymaps = true,
    preferred_picker = "snacks",
  },
  config = function(_, opts)
    require("opencode").setup(opts)
    require("handmade.opencode.operator").setup()
  end,
}
