local M = {}

local Snacks = require("snacks")

---@class ESP32Opts
local defaults = {
	build_dir = "build",
	baudrate = 921600,
}

M.options = vim.deepcopy(defaults)

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.options or {}, opts or {})
	M.ensure_clangd()
end

--- List available cu.* serial ports
function M.list_ports()
	local scandir = vim.uv.fs_scandir("/dev")
	local ports = {}

	if scandir then
		while true do
			local name = vim.uv.fs_scandir_next(scandir)
			if not name then
				break
			end
			if name:match("^ttyUSB") then
				table.insert(ports, { port = "/dev/" .. name })
			end
		end
	end

	return ports
end

--- Find the ESP-IDF specific clangd
function M.find_esp_clangd()
	-- if clangd is on the path, check if it is from espressif using.
	-- if so, we are done
	if vim.fn.executable("clangd") == 1 then
		-- use `clangd --version` to check if it is from espressif
		local clangd_version = vim.fn.system("clangd --version")
		if clangd_version:match("espressif") then
			-- return the absolute path to clangd
			return vim.fn.exepath("clangd")
		end
	end

	local home = vim.env.HOME or vim.fn.expand("~")
	local base = home .. "/.espressif/tools/esp-clang"
	local scandir = vim.uv.fs_scandir(base)
	if not scandir then
		return nil
	end

	local latest
	while true do
		local name = vim.uv.fs_scandir_next(scandir)
		if not name then
			break
		end
		if name:match("^esp%-.+") then
			latest = base .. "/" .. name .. "/esp-clang/bin/clangd"
		end
	end

	return latest
end

--- Ensure compile_commands.json exists
function M.ensure_compile_commands()
	local path = M.options.build_dir .. "/compile_commands.json"
	if vim.fn.filereadable(path) == 0 then
		vim.notify("[ESP32] ⚠️ Missing compile_commands.json in " .. path, vim.log.levels.WARN)
	end
end

--- Ensure esp-clangd exists and warn if not
function M.ensure_clangd()
	if not M.find_esp_clangd() then
		vim.notify("[ESP32] ⚠️ ESP-specific clangd not found. LSP may not work properly.", vim.log.levels.WARN)
	end
end

--- Open a Snacks terminal for idf.py command
function M.command(cmd, port)
	local opts = M.options
	local full_cmd = "idf.py -B " .. opts.build_dir
	if port then
		full_cmd = full_cmd .. " -p " .. port
	end
	full_cmd = full_cmd .. " " .. cmd

	Snacks.terminal.open(full_cmd, {
		win = {
			width = 0.6,
			height = 0.7,
			border = "single",
			title = "Ctrl + ] to stop",
			title_pos = "center",
		},
	})
end

--- Run idf.py build
function M.build()
	local build_dir = M.options.build_dir
	M.command("build")
end

-- Setup build command for Neovim
vim.api.nvim_create_user_command("ESPBuild", function()
	M.build()
end, {})

--- Create Snacks picker for port and run idf.py command
function M.pick(cmd)
	Snacks.picker.pick({
		prompt = "Select ESP32 port",
		ui_select = true,
		focus = "list",
		finder = M.list_ports,
		layout = {
			layout = {
				box = "horizontal",
				width = 0.2,
				height = 0.2,
				{
					box = "vertical",
					border = "single",
					title = "USB Serial Ports",
					{ win = "input", height = 1, border = "bottom" },
					{ win = "list", border = "none" },
				},
			},
		},
		format = function(item)
			local a = Snacks.picker.util.align
			return { { a(item.port, 20, { align = "left" }) } }
		end,
		confirm = function(picker, item)
			picker:close()
			M.command(cmd, item.port)
		end,
	})
end

--- Run idf.py reconfigure for build.clang
function M.reconfigure()
	local build_dir = M.options.build_dir
	Snacks.terminal.open("idf.py -B " .. build_dir .. " reconfigure", {
		win = {
			width = 0.5,
			height = 0.4,
			title = "ESP-IDF Reconfigure",
			title_pos = "center",
		},
	})
end

--- Set up ESP32 LSP configuration
function M.lsp_config()
	local clangd = M.find_esp_clangd()
	if not clangd then
		vim.notify("[ESP32] No esp-clangd found. Falling back to system clangd.", vim.log.levels.WARN)
		clangd = "clangd"
	end
	return {
		cmd = {
			clangd,
			"--compile-commands-dir=" .. M.options.build_dir,
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--function-arg-placeholders",
			"--fallback-style=llvm",
		},
		root_dir = function(fname)
			return require("lspconfig.util").root_pattern("sdkconfig")(fname) or vim.fn.getcwd()
		end,
		capabilities = {
			offsetEncoding = { "utf-16" },
		},
		init_options = {
			usePlaceholders = true,
			completeUnimported = true,
			clangdFileStatus = true,
		},
	}
end

--- Show ESP32 setup info
function M.info()
	local messages = {}

	-- clangd check
	if M.find_esp_clangd() then
		table.insert(messages, "✓ Found esp-clangd")
	else
		table.insert(messages, "✗ ESP-specific clangd missing")
	end

	-- compile_commands.json check
	local build_dir = M.options.build_dir
	local path = build_dir .. "/compile_commands.json"
	if vim.fn.filereadable(path) == 1 then
		table.insert(messages, "✓ compile_commands.json exists")
	else
		table.insert(messages, "✗ compile_commands.json missing")
	end

	-- Check ESP-IDF environment
	local function check_bin(bin)
		return vim.fn.executable(bin) == 1 and "✓" or "✗"
	end

	table.insert(messages, check_bin("idf.py") .. " idf.py")
	table.insert(messages, check_bin("llvm-ar") .. " llvm-ar")
	table.insert(messages, "IDF_PATH: " .. (vim.env.IDF_PATH or "✗ not set"))

	if vim.env.IDF_PATH == nil then
		table.insert(messages, "⚠️ You may need to run: source ~/esp/esp-idf/export.sh")
	end

	vim.notify(table.concat(messages, "\n"), vim.log.levels.INFO)
end

-- Setup custom commands for Neovim
vim.api.nvim_create_user_command("ESPReconfigure", function()
	M.reconfigure()
end, {})

vim.api.nvim_create_user_command("ESPInfo", function()
	M.info()
end, {})

return M
