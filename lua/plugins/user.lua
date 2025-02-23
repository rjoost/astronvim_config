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

  -- Override jay-babu/mason-nvim-dap.nvim
  -- to fix issue with expand path
  -- Add DAP configuration
  {
  "mfussenegger/nvim-dap",
  config = function()
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
        "python",
      },
      handlers = {
        python = function(source_name)
          return  -- Skip default handler since we're configuring manually
        end,
      },
    },
  },
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
        "lua_ls",
        -- add more arguments for adding more language servers
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
  { "vim-airline/vim-airline" },

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

  -- Interactive JQ Buffers (optional)
  {
    "jrop/jq.nvim",
    cmd = { "Jq", "Jqhorizontal" },
    config = function() end,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
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
      local null_ls = require "null-ls"
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
          -- YAML Formatter - stricter than Prettier
          null_ls.builtins.formatting.yamlfmt,
	  -- Prettier Formatter
          null_ls.builtins.formatting.prettier.with({
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
              "--prose-wrap=always" 
            },
          }),

          -- Diagnostics
          -- null_ls.builtins.formatting.yamlfmt, -- stricter than ansible-lint
          null_ls.builtins.diagnostics.yamllint,
          null_ls.builtins.diagnostics.flake8,
          -- null_ls.builtins.diagnostics.ansible_lint, -- for Ansible linting
          -- null_ls.builtins.diagnostics.ansiblelint,
          null_ls.builtins.diagnostics.jsonlint,
          null_ls.builtins.diagnostics.cfn_lint, -- for CloudFormation/AWS

          -- Code Actions
          null_ls.builtins.code_actions.gitsigns,
        },
      }
    end,
  },

  -- Treesitter for better syntax highlighting
  -- Override existing plugins (Example: nvim-treesitter)
  ["nvim-treesitter"] = {
    build = ":TSUpdate",
    config = function()
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
}
