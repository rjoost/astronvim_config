-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- customize alpha options
  {
    "goolord/alpha-nvim",
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

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" }, -- Recognize 'vim' as a global variable
              },
              workspace = {
                library = function()
                  return vim.api.nvim_get_runtime_file("", true) -- Now runs when the setting is accessed
                end,
                checkThirdParty = false,
              },
              telemetry = {
                enable = false, -- Disable telemetry data collection
              },
            },
          },
        },
        yamlls = { -- YAML Language Server
          cmd = { "yaml-language-server", "--stdio" },
          filetypes = { "yaml", "yml" },
          settings = {
            yaml = {
              schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/github-action.json"] = "/action.yml",
                ["https://json.schemastore.org/kubernetes.json"] = "/*.k8s.yaml",
              },
              validate = true,
              hover = true,
              completion = true,
            },
          },
        },
      },
    },
  },

  -- Override jay-babu/mason-nvim-dap.nvim
  -- to fix issue with expand path
  -- Add DAP configuration
  {
    "mfussenegger/nvim-dap",
    config = function()
      local vim = vim
      local dap = require("dap")
    
      -- Use the same Python as set in python3_host_prog
      local python_path = vim.g.python3_host_prog
    
    dap.adapters.python = {
      type = 'executable',
      command = python_path,
      args = { '-m', 'debugpy.adapter' }
    }

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = "${file}",
        pythonPath = function()
          return python_path
        end,
      },
    }
    end,
  },

  -- Keep mason-nvim-dap configuration
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "python", -- I already have debugpy but this keeps it in Mason
      },
    },
  },
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
        -- Python
        "pyright",           -- Fast Python LSP
        -- Shell scripting
        "bashls",           -- Bash/Shell scripting
        
        -- Infrastructure/Cloud
        "docker_compose_language_service", -- Docker compose
        "dockerls",         -- Dockerfile
        "terraformls",
        "yamlls",           -- YAML (useful for Kubernetes, Ansible)
        "ansiblels",        -- Ansible specific
        
        -- Web/Config formats
        "jsonls",           -- JSON
        "lua_ls",           -- Lua
        "taplo",           -- TOML files
        "marksman",          -- Markdown
        
        -- Cloud vendor specific
        -- "aws_cloudformation_yaml_ls", -- AWS CloudFormation
        -- "cfn_lsp",         -- Another CloudFormation LSP
      },
    },
  },

  -- Add mini.icons if you want it
  {
    "echasnovski/mini.icons",
    version = false,
    config = function()
      require("mini.icons").setup()
    end,
  },

  -- Add new plugins
  install = { colorscheme = { "monokai-pro", "tokyonight" } },

  -- Add vim-surround plugin
  { "tpope/vim-surround" },

  -- Add Tokyo Night theme plugin
  { "folke/tokyonight.nvim", config = true },

  -- Add Monokai Pro theme plugin with custom configuration
  {
    "loctvl842/monokai-pro.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      local vim = vim
      require("monokai-pro").setup {
        filter = "pro",
        devicons = true,
        background_clear = {
          "float_win",
          "toggleterm",
          "telescope",
        },
        plugins = {
          bufferline = {
            underline_selected = false,
            underline_visible = false,
          },
        },
      }
      vim.cmd.colorscheme "monokai-pro"
    end,
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true }, -- Dependency for many plugins

  -- Utility library for plugins
  { "nvim-lua/plenary.nvim" },

  -- Keybinding hints
  {
    "folke/which-key.nvim",
    config = function() require("which-key").setup() end,
  },

  -- File Explorer
  { "preservim/nerdtree" },

  -- Status Bar
  { "vim-airline/vim-airline", enabled = false },

  -- Fuzzy Finder
  { "ctrlpvim/ctrlp.vim" },

  -- Code Navigation
  { "majutsushi/tagbar" },

  -- Indent Guides
  { "Yggdroot/indentLine" },

  -- Git Integration
  { "airblade/vim-gitgutter" },

  -- Quick Navigation
  { "easymotion/vim-easymotion" },

  -- Async Tasks
  { "skywind3000/asyncrun.vim" },

  -- JQ Syntax Highlighting
  { "vito-c/jq.vim", ft = { "jq" } },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional icon support
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto", -- or "tokyonight", "gruvbox", "onedark", etc.
          icons_enabled = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "┤", right = "├" },
          -- ... any other lualine options ...
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } }, -- path=1 => show relative path
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        -- You can configure the "inactive" sections or extensions as well:
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  -- Interactive JQ Buffers (optional)
  {
    "jrop/jq.nvim",
    cmd = { "Jq", "Jqhorizontal" },
    config = function() end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    lazy = false, -- <- forces immediate load
  },

  { "norcalli/nvim-colorizer.lua" },
  { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local vim = vim
      local gs = require "gitsigns"
      gs.setup {
        -- Signs configuration
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },

        -- Blame line configuration
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 500, -- Half second delay
        },

        -- Main configuration
        on_attach = function(bufnr)
          -- Helper function for easier keymap setting
          local function map(mode, lhs, rhs, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Next git hunk" })

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Previous git hunk" })

          -- Actions
          map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>hb", gs.blame_line, { desc = "Blame line" })
          map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })

          -- Visual mode mappings
          map(
            "v",
            "<leader>hs",
            function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
            { desc = "Stage selected hunks" }
          )
          map(
            "v",
            "<leader>hr",
            function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
            { desc = "Reset selected hunks" }
          )

          -- Text object for git hunks
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
        end,
      }
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" }, -- Dependency
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup {
        -- To automatically format your Python, YAML, JSON, etc., on save.
        on_attach = function(client, bufnr)
          if client.supports_method "textDocument/formatting" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function() vim.lsp.buf.format { bufnr = bufnr } end,
            })
          end
        end,
        sources = {
          -- Formatters
          null_ls.builtins.formatting.jq,
          null_ls.builtins.formatting.black.with {
            extra_args = { "--line-length=120" },
          },

          null_ls.builtins.diagnostics.pylint.with ({
            extra_args = {
              "--max-line-length=120",
              "--disable=C0111",  -- disable missing docstring warning
              "--disable=missing-docstring",
            },
          }),

          -- YAML Formatter - stricter than Prettier
          null_ls.builtins.formatting.yamlfmt.with {
            extra_args = { "--line-length=120" },
          },
	        -- Prettier Formatter
          null_ls.builtins.formatting.prettier.with ({
            prefer_local = true,
            dynamic_command = function(_)
              return "prettier"
            end,
            extra_args = {
              "--parser=yaml",  -- corrected from filetypes=yaml
              "--no-semi",
              "--single-quote",  -- corrected from single-quote
              "--jsx-single-quote",
              "--tab-width=2",
              "--line-length=120",
              "--prose-wrap=always"
            },
          }),
          -- ADD THIS FOR PHP:
          null_ls.builtins.formatting.prettier.with({
            name = "prettier_php",
            command = "prettier",
            filetypes = { "php" },
            args = { "--stdin-filepath", "$FILENAME", "--parser", "php" },
          }),

          -- open a .md file and do :lua vim.lsp.buf.format()
          null_ls.builtins.formatting.prettier.with({
            name = "prettier_markdown",
            command = "prettier",
            filetypes = { "markdown" },
            args = { "--stdin-filepath", "$FILENAME", "--parser", "markdown" },
          }),

          null_ls.builtins.formatting.prettier.with({
            filetypes = { "yaml", "yml" },
          }),

          -- Diagnostics
          -- null_ls.builtins.formatting.yamlfmt, -- stricter than ansible-lint
          null_ls.builtins.diagnostics.yamllint,
          null_ls.builtins.diagnostics.jsonlint,
          null_ls.builtins.diagnostics.cfn_lint, -- for CloudFormation/AWS

          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.formatting.shfmt,

          -- Code Actions
          null_ls.builtins.code_actions.gitsigns
        },
      }
    end,
  },
  {
    -- Mason integration for null-ls
    "jay-babu/mason-null-ls.nvim",
    config = function(_, opts)
      require("mason-null-ls").setup(opts)
    end,
    opts = {
      ensure_installed = {
        -- Formatters/Linters you want:
      "black",        -- For Python formatting
      "shellcheck",   -- For bash/zsh lint
      "shfmt",        -- For bash/zsh formatting
      "prettier",     -- For JSON/YAML/Markdown formatting
      "jq",           -- For JSON or JQ formatting
      "yamlfmt",      -- For YAML formatting
      "jsonlint",     -- For JSON lint
      },
      automatic_installation = true,
    },
  },

  -- Treesitter for better syntax highlighting
  -- Override existing plugins (Example: nvim-treesitter)
  ["nvim-treesitter"] = {
    build = ":TSUpdate",
    config = function()
      local vim = vim
      -- Setup Treesitter folding
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      -- Don't start with everything folded
      vim.opt.foldenable = false
      vim.opt.foldlevel = 99
      require("nvim-treesitter.configs").setup {

        -- List of parsers to install
        -- note: TSInstall lua python yaml json markdown ...
        --        then, TSInstallInfo
        ensure_installed = {
          "lua",
          "yaml", -- For AWX/Ansible configurations
          "json", -- For AWS configurations and REST API responses
          "python", -- For scripting and automation
          "bash", -- For shell scripting
          "zsh", -- For Zsh-specific scripts
          "lua", -- For Neovim configuration
          "markdown", -- For documentation
          "html", -- For web-based UIs or templates
          "css", -- For styling web components
          "javascript", -- For front-end development or AWS Lambda
          "typescript", -- Same as above but for TypeScript
          "dockerfile", -- For Docker-related workflows
          "ini", -- For configuration files like `.gitconfig`
          "regex", -- Debugging regular expressions
          "sql", -- Database interactions
          "hcl", -- Terraform configurations (if applicable)
        },

	-- Folding configuration
        fold = {
          enable = true,  -- Enable treesitter folding
        },

        -- Automatically install missing parsers when entering a buffer
        auto_install = true,

        -- Synchronize parser installation
        sync_install = false,

        -- Parsers to ignore installing (if any)
        ignore_install = {},

        -- Highlighting configuration
        highlight = {
          enable = true, -- Enable syntax highlighting
          disable = { "query" }, -- Disable problematic query parser
        },

        -- Indentation configuration
        indent = {
          enable = true, -- Enable indentation based on Treesitter
        },

        -- Specify additional modules (optional)
        modules = {},

        -- Custom parser installation directory (optional)
        parser_install_dir = vim.fn.stdpath "data" .. "/treesitter_parsers",
      }
    end,
  },
  { "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },
  {
    "zbirenbaum/copilot.lua", -- https://github.com/zbirenbaum/copilot.lua
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = true },
        panel = { enabled = true },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
    dependencies = { "zbirenbaum/copilot.lua" },
  },
  -- In your plugins/user.lua, or a separate file for nvim-cmp overrides:
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "zbirenbaum/copilot-cmp",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require "cmp"
      -- Insert Copilot source at the top or wherever you want
      table.insert(opts.sources, 1, { name = "copilot", group_index = 2 })
  
      return opts
    end,
  },

  -- Add these to your return table in plugins/user.lua
-- Place them before the final closing brace

  -- Telescope - Fuzzy finder on steroids
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- You already have this
      "nvim-tree/nvim-web-devicons", -- You already have this
      -- Telescope extensions
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
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      
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
            preview_cutoff = 120,
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
            additional_args = function()
              return { "--hidden" }
            end,
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

      -- Load Telescope extensions
      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
      telescope.load_extension("project")
    end,
  },

  -- Python enhancement plugins (these complement your existing Python setup)
  -- For automatic docstring generation
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("neogen").setup({
        enabled = true,
        languages = {
          python = {
            template = {
              annotation_convention = "google_docstrings",
            },
          },
        },
      })
    end,
    cmd = "Neogen",
    keys = {
      { "<Leader>ds", "<cmd>Neogen func<CR>", desc = "Generate function docstring" },
      { "<Leader>dc", "<cmd>Neogen class<CR>", desc = "Generate class docstring" },
    },
  },

  -- For improved Python indentation (you have nvim-treesitter but this adds PEP8 specifics)
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },

  -- For enhanced Python navigation beyond basic treesitter
  {
    "jeetsukumaran/vim-pythonsense",
    ft = "python",
  },

  -- For better YAML support with focus on Ansible (complements your existing YAML support)
  {
    "cuducos/yaml.nvim",
    ft = { "yaml", "yaml.ansible" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
