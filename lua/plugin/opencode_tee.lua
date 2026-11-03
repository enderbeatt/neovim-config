return {
	"enderbeatt/opencode.nvim",
	dir = "/home/enderbeat/dev/opencode.nvim",
	opts = {
		default_global_keymaps = true,
		preferred_picker = "snacks",
		context_breakdown = { enabled = true },
	},
	config = function(_, opts)
		require("opencode").setup(opts)
		require("handmade.opencode.operator").setup()
	end,
}
