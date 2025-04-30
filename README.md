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
- ⚙️ Automatically configures `clangd` for LazyVim LSP

---

## 🚀 Requirements

- [ESP-IDF](https://github.com/espressif/esp-idf) installed and initialized
- ESP-specific `clangd` is installed via `idf_tools.py install esp-clang`
- ESP-specific `clangd` is configured via `idf.py -B build.clang -D IDF_TOOLCHAIN=clang reconfigure` (can be done via command `:ESPReconfigure`)
- [snacks.nvim](https://github.com/folke/snacks.nvim) (automatically installed via LazyVim dependencies)

---

## 📦 Installation (with Lazy.nvim)

Install via Lazy.nvim or any other plugin manager. Via Lazy.nvim:

```lua
{
  "Aietes/esp32.nvim",
}
```

To customize, simply set the `opts` as usual:

```lua
{
  "Aietes/esp32.nvim",
  opts = {
    -- custom build dir
    build_dir = "build.custom",
  },
  keys = {
  {
      -- some other keymap
   "<leader>em",
   function()
    require("esp32").pick("monitor")
   end,
   desc = "ESP32: Pick & Monitor",
  },
  }
}
```

Below is the default configuration:

```lua
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
```

> ⚠️ **Attention:** It's critical to ensure `nvim-lspconfig` is configured to use the ESP-specific `clangd`. This is done in the example below by setting `opts` for `nvim-lspconfig`. The default configuration already does this, but if you are using a different LSP setup, make sure to adjust accordingly.

```lua
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local esp32 = require("esp32")
      opts.servers = opts.servers or {}
      opts.servers.clangd = esp32.lsp_config()
      return opts
    end,
  },
```

---

## 🔧 Configuration

```lua
opts = {
  build_dir = "build.clang", -- directory for CMake builds (must match your clangd compile_commands.json)
}
```

---

## 🛠 Commands

| Command           | Description                                                     |
| :---------------- | :-------------------------------------------------------------- |
| `:ESPReconfigure` | Runs `idf.py -B build.clang -D IDF_TOOLCHAIN=clang reconfigure` |
| `:ESPInfo`        | Shows ESP32 project setup info                                  |
| `pick`            | Pick a serial port and run a command on it.                     |
| `command`         | Run a command (uses last port if needed)                        |

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
- You must either:
  - Use a Nix flake (recommended, see below)
  - Or manually source `~/esp/esp-idf/export.sh` before launching Neovim
- [direnv](https://direnv.net/) or a `flake.nix` is recommended for auto-loading ESP-IDF environments

---

## ❄️ Nix Flake Setup (Recommended)

Using [nix](https://github.com/DeterminateSystems/nix-installer) is highly recommended. Use this `flake.nix` to create a reproducible ESP32 development environment:

```nix
{
  description = "Development ESP32 C3 with ESP-IDF";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ cmake ninja dfu-util python3 ccache ];
          shellHook = ''
            . $HOME/esp/esp-idf/export.sh
          '';
        };
      });
}
```

Then use [direnv](https://direnv.net/) with a `.envrc`:

```bash
touch .envrc
echo 'use flake' > .envrc
direnv allow
```

This will automatically load the environment when you enter the directory.
✅ Now Neovim and the plugin will inherit the full ESP-IDF toolchain environment.

---

## 📜 License

MIT License © 2024 [Aietes](https://github.com/Aietes)
