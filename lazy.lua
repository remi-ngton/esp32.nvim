return {
	{
		name = "esp32.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		opts = {
			build_dir = "build.clang",
		},
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
	},
}
