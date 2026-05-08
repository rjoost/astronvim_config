-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    cond = not vim.g.vscode,
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " █████  ███████ ████████ ██████   ██████",
        "██   ██ ██         ██    ██   ██ ██    ██",
        "███████ ███████    ██    ██████  ██    ██",
        "██   ██      ██    ██    ██   ██ ██    ██",
        "██   ██ ███████    ██    ██   ██  ██████",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      return opts
    end,
  },

  -- flash.nvim: jump anywhere on screen with s + 2 chars
  -- NOTE: 's' no longer acts as Vim's substitute motion. Equivalent is 'cl'.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = false }, -- don't hijack / search
        char = { enabled = true },    -- enhance f/t/F/T motions
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,      desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- Consolidate LuaSnip configuration (keep as is)
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  -- Consolidate nvim-lspconfig configuration (keep as is)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = function() return vim.api.nvim_get_runtime_file("", false) end,
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
      },
    },
  },

  -- Consolidate nvim-dap configuration (keep as is)
  {
    "mfussenegger/nvim-dap",
    config = function()
      local vim = vim
      local dap = require "dap"
      local python_path = vim.g.python3_host_prog

      dap.adapters.python = {
        type = "executable",
        command = python_path,
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function() return python_path end,
        },
      }
    end,
  },

  -- mini.icons
  {
    "echasnovski/mini.icons",
    version = false,
    config = function() require("mini.icons").setup() end,
  },

  -- vim-surround
  { "tpope/vim-surround" },

  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "nvim-lua/plenary.nvim" },
  {
    "folke/which-key.nvim",
    config = function() require("which-key").setup() end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cond = not vim.g.vscode,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-project.nvim",
    },
    cmd = "Telescope",
    event = "VeryLazy",
    config = function()
      local telescope = require "telescope"
      local actions = require "telescope.actions"

      telescope.setup {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 135,
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "__pycache__/",
            "venv/",
            ".venv/",
            "*.pyc",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          live_grep = {
            additional_args = function() return { "--hidden" } end,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          file_browser = {
            theme = "dropdown",
            hijack_netrw = true,
          },
          project = {},
        },
      }
    end,
  },
  { "danymat/neogen", dependencies = "nvim-treesitter/nvim-treesitter" },
  { "Vimjas/vim-python-pep8-indent" },
  { "jeetsukumaran/vim-pythonsense" },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function() require("Comment").setup() end,
  },
  -- Neo-tree config
  {
    "nvim-neo-tree/neo-tree.nvim",
    cond = not vim.g.vscode,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = false, -- eager load so file explorer is always ready
    init = function() vim.g.neo_tree_remove_legacy_commands = true end,
    opts = {
      filesystem = {
        follow_current_file = true,
        hijack_netrw_behavior = "open_current",
      },
    },
  },

  -- Colorizer config
  {
    "norcalli/nvim-colorizer.lua",
    lazy = false, -- Change from event-based loading to eager loading
    config = function() require("colorizer").setup() end,
  },
  -- Todo-comments config
  {
    "folke/todo-comments.nvim",
    cond = not vim.g.vscode,
    dependencies = "nvim-lua/plenary.nvim",
    lazy = false, -- Change from event-based loading to eager loading
    config = function() require("todo-comments").setup() end,
  },

  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("venv-selector").setup {
        name = ".venv",
        auto_refresh = true,
      }
    end,
    event = "VeryLazy",
    keys = { {
      "<leader>vs",
      "<cmd>VenvSelect<cr>",
      desc = "Select VirtualEnv",
    } },
  },

  -- Astrotheme config
  {
    "AstroNvim/astrotheme",
    lazy = false, -- Ensure it's not lazy-loaded
    config = function() require("astrotheme").setup() end,
  },
  { "cuducos/yaml.nvim" },
} -- the next plugin configuration will start here
