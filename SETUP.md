# AstroNvim SRE Config — New Mac Setup

Full step-by-step guide to replicate this configuration on a clean macOS install.
Config repo: `https://github.com/rjoost/astronvim_config.git` (branch: `sre-overhaul`)

---

## 1. Prerequisites

- macOS (Apple Silicon — paths below assume `/opt/homebrew`; Intel uses `/usr/local`)
- Xcode Command Line Tools: `xcode-select --install`
- [Homebrew](https://brew.sh): `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- A [Nerd Font](https://www.nerdfonts.com/) installed and set in your terminal
  - Berkeley Mono Nerd Font is what this config was built with
  - Set it in iTerm2/WezTerm/Ghostty — nvim inherits it from the terminal

---

## 2. Homebrew Packages

```bash
brew install \
  neovim \
  git git-delta git-lfs \
  jq \
  lazygit \
  fzf \
  fd \
  ripgrep \
  node \
  pyenv pyenv-virtualenv \
  gh
```

Add to `~/.zprofile` (login shells — sets up shims on PATH):

```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
```

Add to `~/.zshrc` (interactive shells — enables shell functions):

```bash
command -v pyenv >/dev/null && eval "$(pyenv init -)"
```

---

## 3. Python Setup

This config hardcodes `~/.pyenv/shims/python` as the Neovim Python host (`vim.g.python3_host_prog`).
That shim must resolve to a real Python with pynvim and debugpy.

```bash
# Install a Python version
pyenv install 3.12.4   # or latest stable
pyenv global 3.12.4

# Verify shim works
~/.pyenv/shims/python --version

# Install required Python packages
pip install pynvim debugpy ansible ansible-lint yamllint ruff
```

---

## 4. Node / npm Packages

```bash
# pyright LSP (Python language server)
npm install -g pyright
```

---

## 5. GitHub CLI Auth (for octo.nvim)

```bash
gh auth login
# Follow prompts: GitHub.com → HTTPS → authenticate via browser
```

---

## 6. Clone the Config

```bash
# Back up any existing nvim config
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# Clone
git clone https://github.com/rjoost/astronvim_config.git ~/.config/nvim
cd ~/.config/nvim
git checkout sre-overhaul
```

---

## 7. First Launch

```bash
nvim
```

On first launch, Lazy.nvim bootstraps itself automatically, then installs all plugins.
This takes 2–5 minutes. What happens in order:

1. **Lazy.nvim** clones itself and all ~60 plugins
2. **Mason** auto-installs LSP servers: `lua_ls`, `ansiblels`, `dockerls`
3. **mason-null-ls** auto-installs tools: `stylua`, `ruff`, `yamllint`, `ansible-lint`
4. **mason-nvim-dap** auto-installs: `python` (debugpy adapter)
5. **Treesitter** auto-installs parsers: lua, vim, python, yaml, json, markdown, bash, regex

Wait for all installers to complete before using nvim. You can watch progress with `:Lazy` and `:Mason`.

---

## 8. Post-Install Verification

Run these checks after first launch completes:

| Check | Command | Expected |
|-------|---------|----------|
| General health | `:checkhealth` | No errors (warnings OK) |
| Mason tools | `:Mason` | All green |
| Python LSP | Open `.py` file → `:LspInfo` | `pyright` attached |
| YAML LSP | Open `.yml` file → `:LspInfo` | `yamlls` attached |
| Ansible LSP | Open `yaml.ansible` file → `:LspInfo` | `ansiblels` attached |
| lazygit | `<Leader>gg` | lazygit TUI opens |
| flash.nvim | `s` in normal mode | Jump UI appears |
| Linting | Open `.py`, save | ruff diagnostics in gutter |
| Telescope | `<Leader>tf` | File picker opens |
| Neotree | `<Leader>e` | File explorer opens |

---

## 9. Key Bindings Reference

**Leader key: `<Space>`**

### Navigation
| Key | Action |
|-----|--------|
| `s` | flash.nvim jump (2-char) |
| `S` | flash.nvim treesitter select |
| `<Leader>e` | Toggle Neotree |
| `<Leader>o` | Focus Neotree |

### Telescope
| Key | Action |
|-----|--------|
| `<Leader>tf` | Find files |
| `<Leader>tg` | Live grep |
| `<Leader>tb` | Buffers |
| `<Leader>tR` | Recent files |
| `<Leader>to` | Search TODO/FIXME/BUG/HACK/NOTE |
| `<Leader>te` | File browser |
| `<Leader>tP` | Projects |
| `<Leader>ts` | LSP document symbols |
| `<Leader>tS` | LSP workspace symbols |
| `<Leader>tr` | LSP references |

### Git
| Key | Action |
|-----|--------|
| `<Leader>gg` | Open lazygit |
| `<Leader>gc` | Git commits (Telescope) |
| `<Leader>gb` | Git branches (Telescope) |
| `<Leader>gs` | Git status (Telescope) |

### Octo (GitHub — prefix `<Leader>go`)
| Key | Action |
|-----|--------|
| `<Leader>gopl` | List open PRs |
| `<Leader>gopn` | Create PR |
| `<Leader>gopo` | Checkout PR |
| `<Leader>gopk` | PR CI checks |
| `<Leader>goil` | List issues |
| `<Leader>gors` | Start review |
| `<Leader>gorf` | Submit review |

### Paste
| Key | Action |
|-----|--------|
| `<Leader>fp` | Format-preserving paste |
| `<Leader>V` | Clean paste from clipboard |
| `<Leader>tp` | Toggle paste mode |

### LSP / Code
| Key | Action |
|-----|--------|
| `<Leader>ff` | LSP format buffer |
| `<Leader>yf` | Format YAML (LSP) |
| `<Leader>fj` | Format JSON with jq |
| `<Leader>b` | Toggle DAP breakpoint (Python) |
| `<F5>` | DAP continue |
| `<F10>` | DAP step over |
| `<F11>` | DAP step into |

### Neotest (Python)
| Key | Action |
|-----|--------|
| `<Leader>nn` | Run nearest test |
| `<Leader>nf` | Run all tests in file |
| `<Leader>no` | Toggle test output panel |

### Python
| Key | Action |
|-----|--------|
| `<Leader>vs` | Select virtualenv |
| `<Leader>pr` | Run current Python file |
| `<Leader>pd` | Generate docstring (neogen) |

---

## 10. LSP Configuration Notes

### YAML / Ansible
- `yamlls` handles generic YAML with SchemaStore schemas
- `ansiblels` handles `yaml.ansible` filetype only
- Auto-formatting is **disabled** for YAML/Ansible (prevents mangling empty lines)
- Ansible-lint runs on save via nvim-lint for `yaml.ansible` files

### Python
- `pyright` for LSP (type checking set to `off` — ruff handles linting)
- `ruff` runs on save via nvim-lint
- `debugpy` adapter configured for DAP (F5/F10/F11 keys)
- virtualenv selection via `<Leader>vs` (venv-selector.nvim)

### JSON
- `jsonls` with SchemaStore schemas
- `jq` auto-formats on save

---

## 11. Critical Gotchas

These burned hours and are already solved in the repo — **do not undo them**:

1. **SchemaStore at parse time** (`astrolsp.lua`): `require("schemastore")` is inside
   `opts = function(_, opts)`, not a plain table. If converted to a table, it fires at
   spec-parse time before plugins are loaded and crashes.

2. **macOS HFS+ SchemaStore case conflict** (`sre.lua`): `astrocommunity.pack.docker` →
   `pack.yaml` declares `"b0o/schemastore.nvim"` (lowercase). macOS HFS+ is case-insensitive,
   so declaring `"b0o/SchemaStore.nvim"` separately creates an infinite install loop.
   SchemaStore is intentionally NOT declared in `sre.lua` — let the docker pack own it.

3. **`lazyredraw = false`** (`astrocore.lua`): noice.nvim hard-breaks with `lazyredraw = true`.

4. **`cmdheight = 0`** (`astrocore.lua`): Required for noice.nvim floating cmdline.

5. **`diagnostics_mode = 3`** (`astrocore.lua`): Must be 3 (fully on) or nvim-lint diagnostics
   won't display.

6. **Mason vs lspconfig names**: `:MasonInstall ansible-language-server` (Mason package name).
   lspconfig uses `ansiblels`. These are different — mason-lspconfig maps between them.

7. **docker pack lspconfig fix** (`mason.lua`): `astrocommunity.pack.docker` incorrectly adds
   `"docker-language-server"` (Mason name) to mason-lspconfig's `ensure_installed`, which
   expects lspconfig names. `mason.lua` filters it out and adds `"dockerls"` instead.

8. **`max_rounds = 30`** (`lazy_setup.lua`): Lazy.nvim's default of 10 rounds is not enough
   when many AstroCommunity packs are imported simultaneously. Raised to 30.

9. **git path hardcoded** (`lazy_setup.lua`): `git.cmd = "/opt/homebrew/bin/git"`. This is
   correct for Apple Silicon. On Intel Mac, change to `/usr/local/bin/git`.

---

## 12. File Structure

```
~/.config/nvim/
├── init.lua                    # Entry point; detects VSCode, sets python path
├── lua/
│   ├── lazy_setup.lua          # Lazy.nvim bootstrap + config
│   ├── community.lua           # AstroCommunity packs
│   ├── polish.lua              # Editor opts, keymaps, autocommands (runs last)
│   ├── vscode_lazy_setup.lua   # Minimal setup when running inside VSCode
│   ├── vscode.lua              # VSCode-specific config
│   └── plugins/
│       ├── astrocore.lua       # Editor options, buffer/neotest keymaps
│       ├── astrolsp.lua        # LSP servers: yamlls, jsonls, ansiblels
│       ├── astroui.lua         # Colorscheme, highlight overrides
│       ├── catppuccin.lua      # Catppuccin mocha theme config
│       ├── mason.lua           # Mason server/tool auto-install list
│       ├── treesitter.lua      # Treesitter parser list
│       ├── none-ls.lua         # null-ls: disable YAML formatting
│       ├── sre.lua             # nvim-lint + neotest (core SRE tools)
│       ├── lazygit.lua         # lazygit.nvim
│       ├── octo.lua            # octo.nvim keybinding overrides
│       └── user.lua            # flash.nvim, telescope, dap, venv-selector, etc.
```

---

## 13. Updating

```bash
# Update plugins
:Lazy update

# Update Mason tools
:MasonUpdate

# Pull config changes
cd ~/.config/nvim && git pull
```
