return {
	"Aietes/esp32.nvim",
	name = "esp32.nvim",
	dependencies = {
		"folke/snacks.nvim",
		{
			"neovim/nvim-lspconfig",
			opts = function(_, opts)
				local esp32 = require("esp32")
				opts.servers = opts.servers or {}
				opts.servers.clangd = esp32.lsp_config()
				return opts
			end,
		},
	},
	opts = {
		build_dir = "build.clang",
	},
	config = function(_, opts)
		require("esp32").setup(opts)
	end,
	keys = {
		{
			"<leader>RM",
			function()
				require("esp32").pick("monitor")
			end,
			desc = "ESP32: Pick & Monitor",
		},
		{
			"<leader>Rm",
			function()
				require("esp32").command("monitor")
			end,
			desc = "ESP32: Monitor",
		},
		{
			"<leader>RF",
			function()
				require("esp32").pick("flash")
			end,
			desc = "ESP32: Pick & Flash",
		},
		{
			"<leader>Rf",
			function()
				require("esp32").command("flash")
			end,
			desc = "ESP32: Flash",
		},
		{
			"<leader>Rc",
			function()
				require("esp32").command("menuconfig")
			end,
			desc = "ESP32: Configure",
		},
		{
			"<leader>RC",
			function()
				require("esp32").command("clean")
			end,
			desc = "ESP32: Clean",
		},
		{ "<leader>Rr", ":ESPReconfigure<CR>", desc = "ESP32: Reconfigure project" },
		{ "<leader>Ri", ":ESPInfo<CR>", desc = "ESP32: Project Info" },
	},
}
