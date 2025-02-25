-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

return function()
  -- Make a local reference to the global vim variable
  local vim = vim
  -- Global Variables
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Configure diagnostics display for better error visualization
  -- Add this near the beginning of your polish.lua function
  vim.diagnostic.config({
    virtual_text = {
      prefix = '●', -- Could be '■', '▎', 'x', etc
      spacing = 4,
      source = "if_many",
      severity = {
        min = vim.diagnostic.severity.HINT,
      },
    },
    float = {
      source = true,
      border = "rounded",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- Customize diagnostic signs
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- Load essential plugins immediately
  local plugins_to_load = {
    "lewis6991/gitsigns.nvim",
    "jrop/jq.nvim",
    "folke/lazydev.nvim",        -- Only include if you've added it above
    "nvim-neo-tree/neo-tree.nvim",
    "norcalli/nvim-colorizer.lua",
    "nvim-lua/plenary.nvim",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope.nvim",
  }

  for _, plugin in ipairs(plugins_to_load) do
    require("lazy").load({ plugins = { plugin } })
  end

  -- Editor Options
  local opt = vim.opt
  opt.clipboard = "unnamedplus"   -- Use system clipboard
  opt.number = false              -- No line numbers
  opt.relativenumber = false      -- No relative line numbers
  opt.tabstop = 2                 -- Number of spaces for tab
  opt.shiftwidth = 2              -- Number of spaces for autoindent
  opt.expandtab = true            -- Convert tabs to spaces
  opt.termguicolors = true        -- True color support

  -- Treesitter Configuration
  opt.runtimepath:append(vim.fn.stdpath "data" .. "/treesitter_parsers")

  -- Theme Setting
  vim.cmd.colorscheme "monokai-pro"

  -- Create autocommands
  local autocmd = vim.api.nvim_create_autocmd

  -- Remove trailing whitespace on save
  autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
      local cursor_pos = vim.fn.getcurpos()
      vim.cmd([[%s/\s\+$//e]])
      vim.fn.setpos('.', cursor_pos)
    end,
    desc = "Remove trailing whitespace on save",
  })

  -- Ensure early loading of specific plugins
  autocmd("VimEnter", {
    callback = function()
      vim.schedule(function()
        require("lazy").load({
          plugins = {
            "lewis6991/gitsigns.nvim",
            "jrop/jq.nvim",
            "folke/lazydev.nvim",        -- Only include if you've added it above
            "nvim-neo-tree/neo-tree.nvim",
            "norcalli/nvim-colorizer.lua",
            "nvim-lua/plenary.nvim",
            "folke/todo-comments.nvim",
          }
        })
      end)
    end,
    desc = "Load essential plugins early",
  })

  -- YAML-specific settings (new additions)
  autocmd("FileType", {
    pattern = { "yaml", "yml", "yaml.ansible" },
    callback = function()
      local opts = { noremap = true, silent = true }
      local keymap = vim.keymap.set

      -- Set YAML-specific options for indentation and formatting
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2

      -- Add ansible filetype detection for improved syntax highlighting (optional)
      autocmd("BufRead,BufNewFile", {
        pattern = { "*/playbooks/*.yml", "*/roles/*.yml", "*/inventory/*.yml" },
        command = "set filetype=yaml.ansible",
        desc = "Set Ansible YAML filetype for better syntax highlighting",
      })

      -- Keybinding: Format YAML file using LSP formatting
      keymap("n", "<Leader>yf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
    end,
    desc = "YAML file settings and keybindings",
  })

  -- JQ Configuration
  local opts = { noremap = true, silent = true }

  -- JQ Keybindings
  local keymap = vim.keymap.set
  keymap("n", "<Leader>fj", "<Cmd>%!jq<CR>", opts)                    -- Format entire buffer
  keymap("n", "<Leader>fcj", "<Cmd>%!jq --compact-output<CR>", opts)  -- Minify entire buffer
  keymap("v", "<Leader>fj", ":'<,'>!jq<CR>", opts)                    -- Format selection
  keymap("v", "<Leader>fcj", ":'<,'>!jq --compact-output<CR>", opts)  -- Minify selection

  -- Main telescope functions
  keymap("n", "<Leader>tf", "<cmd>Telescope find_files<CR>", opts)    -- Find files
  keymap("n", "<Leader>tg", "<cmd>Telescope live_grep<CR>", opts)     -- Find text in files
  keymap("n", "<Leader>tb", "<cmd>Telescope buffers<CR>", opts)       -- Find open buffers
  keymap("n", "<Leader>th", "<cmd>Telescope help_tags<CR>", opts)     -- Find help tags
  keymap("n", "<Leader>tr", "<cmd>Telescope oldfiles<CR>", opts)      -- Find recent files
  keymap("n", "<Leader>tc", "<cmd>Telescope colorscheme<CR>", opts)   -- Find colorschemes

  -- Project management
  keymap("n", "<Leader>tp", "<cmd>Telescope project<CR>", opts)       -- Find projects

  -- File browser
  keymap("n", "<Leader>te", "<cmd>Telescope file_browser<CR>", opts)  -- File explorer

  -- LSP related
  keymap("n", "<Leader>ts", "<cmd>Telescope lsp_document_symbols<CR>", opts)    -- Document symbols
  keymap("n", "<Leader>tS", "<cmd>Telescope lsp_workspace_symbols<CR>", opts)   -- Workspace symbols
  keymap("n", "<Leader>td", "<cmd>Telescope lsp_definitions<CR>", opts)         -- Go to definition
  keymap("n", "<Leader>tt", "<cmd>Telescope lsp_type_definitions<CR>", opts)    -- Go to type definition
  keymap("n", "<Leader>tr", "<cmd>Telescope lsp_references<CR>", opts)          -- Find references
  keymap("n", "<Leader>ti", "<cmd>Telescope lsp_implementations<CR>", opts)     -- Find implementations

  -- Git operations
  keymap("n", "<Leader>gc", "<cmd>Telescope git_commits<CR>", opts)   -- Git commits
  keymap("n", "<Leader>gb", "<cmd>Telescope git_branches<CR>", opts)  -- Git branches
  keymap("n", "<Leader>gs", "<cmd>Telescope git_status<CR>", opts)    -- Git status

  -- Custom Telescope functions
  -- Find Python files only
  keymap("n", "<Leader>py", "<cmd>Telescope find_files find_command=find,.,'-name','*.py'<CR>", opts)

  -- Find Ansible YAML files
  keymap("n", "<Leader>ya", "<cmd>Telescope find_files find_command=find,.,'-name','*.yml','-o','-name','*.yaml'<CR>", opts)

  -- Find JSON files
  keymap("n", "<Leader>js", "<cmd>Telescope find_files find_command=find,.,'-name','*.json'<CR>", opts)

  -- Find TODOs
  keymap("n", "<Leader>to", "<cmd>Telescope grep_string search='TODO\\|FIXME\\|BUG\\|HACK\\|NOTE'<CR>", opts)

  -- Automatically format JSON on save
  autocmd("BufWritePre", {
    pattern = "*.json",
    callback = function()
      vim.cmd([[%!jq]])
    end,
    desc = "Format JSON files with jq on save",
  })

  -- LSP Format keybinding
  keymap("n", "<Leader>ff", "<cmd>lua vim.lsp.buf.format()<CR>", opts)

  -- Create autocommands for Python files
  autocmd("FileType", {
    pattern = "python",
    callback = function()
      -- Set Python-specific options
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.colorcolumn = "88"  -- For Black formatter line length

      -- Python specific keymappings
      keymap("n", "<F5>", "<cmd>lua require('dap').continue()<CR>", opts)
      keymap("n", "<F10>", "<cmd>lua require('dap').step_over()<CR>", opts)
      keymap("n", "<F11>", "<cmd>lua require('dap').step_into()<CR>", opts)
      keymap("n", "<F12>", "<cmd>lua require('dap').step_out()<CR>", opts)
      keymap("n", "<Leader>b", "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)
      keymap("n", "<Leader>dr", "<cmd>lua require('dap').repl.open()<CR>", opts)

      -- Auto-generate docstring shortcut
      keymap("n", "<Leader>pd", "<cmd>Neogen func<CR>", opts)

      -- Run current Python file
      keymap("n", "<Leader>pr", "<cmd>!python %<CR>", opts)
    end,
    desc = "Python file settings",
  })

  -- Create autocommands for YAML files
  autocmd("FileType", {
    pattern = { "yaml", "yaml.ansible" },
    callback = function()
      -- Set YAML-specific options
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2

      -- Add ansible filetype detection for improved syntax highlighting
      autocmd("BufRead,BufNewFile", {
        pattern = { "*/playbooks/*.yml", "*/roles/*.yml", "*/inventory/*.yml" },
        command = "set filetype=yaml.ansible",
      })

      -- YAML formatting on save
      keymap("n", "<Leader>yf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
    end,
    desc = "YAML file settings",
  })

  -- JSON-specific settings
  autocmd("FileType", {
    pattern = "json",
    callback = function()
      -- Set JSON-specific options
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2

      -- Additional JSON keymappings beyond what you already have
      keymap("n", "<Leader>jp", "<cmd>%!python -m json.tool<CR>", opts)  -- Alternative JSON formatter
    end,
    desc = "JSON file settings",
  })
end

