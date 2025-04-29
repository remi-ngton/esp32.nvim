# esp32.nvim

**ESP32 development helper for Neovim.**  
Designed for a smooth ESP-IDF workflow inside Neovim and [LazyVim](https://github.com/LazyVim/LazyVim).  
Uses [snacks.nvim](https://github.com/folke/snacks.nvim) for terminal and picker UIs.

---

## ✨ Features

- 🧠 Automatically detects ESP-IDF-specific `clangd`
- 🛠 Configures `build_dir` (`build.clang`) for IDF builds
- 🖥️ Launch `idf.py monitor` and `idf.py flash` in floating terminals
- 🔎 Pick available USB serial ports dynamically
- 📋 Check project setup with `:ESPInfo`
- 🛠 Quickly run reconfigure with `:ESPReconfigure`

---

## 🚀 Requirements

- [ESP-IDF](https://github.com/espressif/esp-idf) installed and initialized
- `idf_tools.py install esp-clang`
- `idf.py -B build.clang -D IDF_TOOLCHAIN=clang reconfigure`
- [snacks.nvim](https://github.com/folke/snacks.nvim) (automatically installed via LazyVim dependencies)

---

## 📦 Installation (with Lazy.nvim)

```lua
{
  "Aietes/esp32.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    build_dir = "build.clang", -- default (can be customized)
    baudrate = 115200,         -- reserved for future use
  },
  keys = {
    { "<leader>RM", function() require("esp32").create_picker("monitor") end, desc = "ESP32: Pick & Monitor" },
    { "<leader>Rm", function() require("esp32").open_terminal("monitor") end, desc = "ESP32: Monitor" },
    { "<leader>RF", function() require("esp32").create_picker("flash") end, desc = "ESP32: Pick & Flash" },
    { "<leader>Rf", function() require("esp32").open_terminal("flash") end, desc = "ESP32: Flash" },
    { "<leader>Rr", ":ESPReconfigure<CR>", desc = "ESP32: Reconfigure project" },
    { "<leader>Ri", ":ESPInfo<CR>", desc = "ESP32: Project Info" },
  },
}
```

---

## 🔧 Configuration

```lua
opts = {
  build_dir = "build.clang", -- directory for CMake builds (must match your clangd compile_commands.json)
  baudrate = 115200,         -- (reserved for future use)
}
```

---

## 🛠 Commands

| Command           | Description                                                     |
| :---------------- | :-------------------------------------------------------------- |
| `:ESPReconfigure` | Runs `idf.py -B build.clang -D IDF_TOOLCHAIN=clang reconfigure` |
| `:ESPInfo`        | Shows ESP32 project setup info                                  |
| `<leader>RM`      | Pick a serial port and monitor                                  |
| `<leader>RF`      | Pick a serial port and flash                                    |
| `<leader>Rm`      | Monitor directly without picking                                |
| `<leader>Rf`      | Flash directly without picking                                  |

---

## ⚙️ Recommended ESP-IDF Setup

Clone and install ESP-IDF:

```bash
mkdir -p ~/esp
cd ~/esp
git clone --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
./install.sh esp32c3
```

Install the Espressif-specific `clangd`:

```bash
idf_tools.py install esp-clang
```

Create your build directory using clang:

```bash
idf.py -B build.clang -D IDF_TOOLCHAIN=clang reconfigure
```

From now on, **always** build and flash using:

```bash
idf.py -B build.clang build
idf.py -B build.clang flash
```

---

## 📋 Notes

- This plugin does **not** install ESP-IDF automatically.
- You should ensure your environment (`$PATH`, etc.) is correctly initialized.
- [direnv](https://direnv.net/) or a `flake.nix` is recommended for auto-loading ESP-IDF environments.

---

## 📜 License

MIT License © 2024 [Aietes]
