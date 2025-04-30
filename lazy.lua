return {
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
		baudrate = 115200,
	},
	config = function(_, opts)
		require("esp32").setup(opts)
	end,
	keys = {
		{
			"<leader>RM",
			function()
				require("esp32").create_picker("monitor")
			end,
			desc = "ESP32: Pick & Monitor",
		},
		{
			"<leader>Rm",
			function()
				require("esp32").open_terminal("monitor")
			end,
			desc = "ESP32: Monitor",
		},
		{
			"<leader>RF",
			function()
				require("esp32").create_picker("flash")
			end,
			desc = "ESP32: Pick & Flash",
		},
		{
			"<leader>Rf",
			function()
				require("esp32").open_terminal("flash")
			end,
			desc = "ESP32: Flash",
		},
		{ "<leader>Rr", ":ESPReconfigure<CR>", desc = "ESP32: Reconfigure project" },
		{ "<leader>Ri", ":ESPInfo<CR>", desc = "ESP32: Project Info" },
	},

	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			local esp32 = require("esp32")
			opts.servers = opts.servers or {}
			opts.servers.clangd = esp32.lsp_config()
			return opts
		end,
	},
}
