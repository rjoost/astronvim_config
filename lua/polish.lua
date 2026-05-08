-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Ensure Git is in the PATH for Neovim
local home = os.getenv "HOME"
local path = os.getenv "PATH"

-- Add Homebrew bin directories to PATH if not already present
if not path:find "/opt/homebrew/bin" then vim.env.PATH = "/opt/homebrew/bin:" .. (path or "") end
if not path:find "/usr/local/bin" then vim.env.PATH = "/usr/local/bin:" .. vim.env.PATH end

-- Add CheckFormatters command (ADD THIS HERE, OUTSIDE THE FUNCTION)
vim.api.nvim_create_user_command("CheckFormatters", function()
  local active_clients = vim.lsp.get_active_clients()
  local message = "Active LSP clients for this buffer:\n"

  for _, client in ipairs(active_clients) do
    local capabilities = client.server_capabilities
    message = message
      .. client.name
      .. " (formatting: "
      .. tostring(capabilities.documentFormattingProvider or false)
      .. ")\n"
  end

  vim.api.nvim_echo({ { message, "Normal" } }, true, {})
end, {})

return function()
  -- Add FZF Runtime Path
  vim.opt.rtp:append "/opt/homebrew/opt/fzf/share/fzf/runtime"

  -- Make a local reference to the global vim variable
  local vim = vim

  -- Global Variables
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Editor Options
  local opt = vim.opt
  opt.clipboard = "unnamedplus" -- Use system clipboard
  opt.number = false -- No line numbers
  opt.relativenumber = false -- No relative line numbers
  opt.tabstop = 2 -- Number of spaces for tab
  opt.shiftwidth = 2 -- Number of spaces for autoindent
  opt.expandtab = true -- Convert tabs to spaces
  opt.termguicolors = true -- True color support
  opt.linespace = 4 -- Extra space between lines (Berkeley Mono)

  -- Better paste handling settings
  opt.pastetoggle = "<F2>" -- Toggle paste mode with F2
  opt.formatoptions:remove { "t", "c" } -- Don't auto-wrap text or comments when pasting
  opt.formatoptions:append "q" -- Allow formatting of comments with 'gq'
  opt.showmode = true -- Show when paste mode is active

  -- Setup a minimal status line with paste mode indicator
  opt.statusline = " %f %m%r%h%w%=%{&paste?'[PASTE] ':''}%y %l,%c %P "

  -- Make paste mode very visible in the status line
  vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "paste",
    callback = function()
      if vim.opt.paste:get() then
        vim.opt.statusline = "-- PASTE MODE -- " .. vim.opt.statusline:get()
      else
        vim.opt.statusline = vim.opt.statusline:get():gsub("-- PASTE MODE -- ", "")
      end
    end,
  })

  -- Add this clipboard diagnostic command
  vim.api.nvim_create_user_command("CheckClipboard", function()
    local has_clipboard = vim.fn.has "clipboard"
    local clipboard_tool = ""

    if vim.fn.executable "pbcopy" == 1 then
      clipboard_tool = "pbcopy/pbpaste (macOS native)"
    elseif vim.fn.executable "xclip" == 1 then
      clipboard_tool = "xclip"
    elseif vim.fn.executable "xsel" == 1 then
      clipboard_tool = "xsel"
    end

    local message = "Clipboard support: " .. (has_clipboard == 1 and "Yes" or "No") .. "\n"
    message = message .. "Clipboard tool: " .. (clipboard_tool ~= "" and clipboard_tool or "None detected") .. "\n"
    message = message .. "Clipboard option: " .. vim.inspect(vim.opt.clipboard:get()) .. "\n"

    vim.api.nvim_echo({ { message, "Normal" } }, true, {})
  end, {})

  -- Add a Super Paste command for ultimate paste flexibility
  vim.api.nvim_create_user_command("SuperPaste", function(opts)
    -- Save state
    local old_paste = vim.opt.paste:get()
    local old_autoindent = vim.opt.autoindent:get()

    -- Enable optimal paste environment
    vim.opt.paste = true
    vim.opt.autoindent = false

    -- Handle different modes and register sources
    if opts.args == "clipboard" then
      if vim.fn.mode() == "i" then
        -- Insert mode, clipboard
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>+", true, false, true), "n", false)
      else
        -- Normal mode, clipboard
        vim.cmd 'normal! "+p'
      end
    else
      -- Default register
      if vim.fn.mode() == "i" then
        -- Insert mode, default register
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-r>"', true, false, true), "n", false)
      else
        -- Normal mode, default register
        vim.cmd "normal! p"
      end
    end

    -- Restore state with slight delay to ensure paste completes
    vim.defer_fn(function()
      vim.opt.paste = old_paste
      vim.opt.autoindent = old_autoindent
    end, 100)
  end, { nargs = "?", complete = function() return { "clipboard" } end })

  -- Treesitter Configuration
  opt.runtimepath:append(vim.fn.stdpath "data" .. "/treesitter_parsers")

  -- Add this to disable LSP formatting capabilities
  local lsp = require "lspconfig"
  lsp.pyright.setup {
    on_attach = on_attach,
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "off",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  }

  -- Configure diagnostics
  vim.diagnostic.config {
    virtual_text = {
      prefix = "●", -- Use a clear diagnostic symbol
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
  }

  -- Customize diagnostic signs
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- Create autocommands
  local autocmd = vim.api.nvim_create_autocmd

  -- CONSOLIDATED YAML SETTINGS - REPLACED MULTIPLE DUPLICATIVE AUTOCOMMANDS
  autocmd("FileType", {
    pattern = { "yaml", "yml", "yaml.ansible" },
    callback = function()
      -- Set YAML-specific options for indentation and formatting
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.linenumber = false
      vim.opt_local.termguicolors = true
      vim.opt_local.number = false

      -- IMPORTANT: Disable auto-formatting for YAML files
      -- This prevents the removal of empty lines after front matter
      vim.b.autoformat = false

      -- Disable formatoptions that would affect YAML structure
      -- vim.opt_local.formatoptions:remove { "t", "c", "r", "o" }
      vim.opt_local.formatoptions = ""
      vim.bo.formatexpr = "" -- Clear any format expression

      -- Add ansible filetype detection for improved syntax highlighting
      autocmd("BufRead,BufNewFile", {
        pattern = { "*/playbooks/*.yml", "*/roles/*.yml", "*/inventory/*.yml" },
        command = "set filetype=yaml.ansible",
      })

      -- IMPORTANT: Create a specific BufWritePre handler for this buffer
      -- that cancels any other BufWritePre handlers that might affect whitespace
      autocmd("BufWritePre", {
        buffer = 0, -- Use current buffer
        callback = function()
          -- This handler runs first and returns true to indicate
          -- that we don't want other matching handlers to run
          -- This preserves empty lines in YAML files including after front matter
          return true
        end,
        desc = "Preserve empty lines in YAML files",
        -- Use a higher priority than other BufWritePre autocommands
        priority = 1000,
      })

      -- Keybinding: Format YAML file using LSP formatting
      local opts = { noremap = true, silent = true }
      local keymap = vim.keymap.set
      keymap("n", "<Leader>yf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
    end,
    desc = "YAML file settings - consolidated configuration",
  })

  -- Remove trailing whitespace on save (preserving empty lines)
  -- MODIFIED to ensure it doesn't affect YAML files
  autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
      -- Skip YAML files completely
      local ft = vim.bo.filetype
      if ft == "yaml" or ft == "yml" or ft == "yaml.ansible" then return end

      local cursor_pos = vim.fn.getcurpos()
      vim.cmd [[%s/\s\+$//e]]
      vim.fn.setpos(".", cursor_pos)
    end,
    desc = "Remove trailing whitespace on save (except for YAML files)",
    -- Lower priority so YAML-specific handlers take precedence
    priority = 100,
  })

  -- Optimized plugin loading sequence
  autocmd("VimEnter", {
    callback = function()
      vim.schedule(function()
        -- Load critical plugins first
        require("lazy").load {
          plugins = {
            "plenary.nvim", -- Add this first as many plugins depend on it
            "nvim-web-devicons", -- Add this early for UI
          },
          force = true,
        }

        -- Small delay to let critical plugins initialize
        vim.defer_fn(function()
          -- Then load functional plugins
          require("lazy").load {
            plugins = {
              -- "tokyonight.nvim", -- Remove or comment this out since it's loaded via tokyonight.lua
              "neo-tree.nvim",
              "nvim-colorizer.lua",
              "todo-comments.nvim",
            },
            force = true,
          }

          -- Apply colorscheme explicitly
          -- pcall(function() vim.cmd.colorscheme "tokyonight" end) -- Remove or comment this out
          -- Ensure setups are called in the correct order
          pcall(function() require("colorizer").setup() end)
          pcall(function() require("todo-comments").setup() end)
          pcall(function() require "neo-tree" end)
        end, 50) -- 50ms delay
      end)
    end,
    desc = "Optimized plugin loading sequence",
  })

  -- Create the autocommand group
  local augroup_folding = vim.api.nvim_create_augroup("AddVimFoldingComment", { clear = true })

  -- Improved BufWritePre for YAML files
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.yml", "*.yaml", "*.ansible.yml" },
    callback = function()
      -- Get buffer info
      local buf = vim.api.nvim_get_current_buf()
      local comment = "# vim:foldmethod=marker:foldmarker={{{,}}}:ft=yaml.ansible"

      -- Get line count
      local line_count = vim.api.nvim_buf_line_count(buf)
      if line_count > 0 then
        -- Check last line
        local last_line = vim.api.nvim_buf_get_lines(buf, line_count - 1, line_count, false)[1]
        -- Only add if not already present
        if last_line ~= comment then vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, { comment }) end
      end
    end,
    group = augroup_folding,
    -- Lower priority than the YAML empty line preservation
    priority = 500,
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

      -- Additional JSON keymappings
      local opts = { noremap = true, silent = true }
      local keymap = vim.keymap.set
      keymap("n", "<Leader>jp", "<cmd>%!python -m json.tool<CR>", opts) -- Alternative JSON formatter
    end,
    desc = "JSON file settings",
  })

  -- Create autocommands for Python files
  autocmd("FileType", {
    pattern = "python",
    callback = function()
      -- Set Python-specific options
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.colorcolumn = "88" -- For Black formatter line length

      -- Python specific keymappings
      local opts = { noremap = true, silent = true }
      local keymap = vim.keymap.set
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

  -- Automatically format JSON on save
  autocmd("BufWritePre", {
    pattern = "*.json",
    callback = function() vim.cmd [[%!jq]] end,
    desc = "Format JSON files with jq on save",
  })

  -- All keybinding configurations
  local opts = { noremap = true, silent = true }
  local keymap = vim.keymap.set

  -- Paste-related keybindings
  keymap("n", "<Leader>tp", ":set paste!<CR>", { noremap = true, silent = true, desc = "Toggle paste mode" })
  keymap("i", "<C-v>", "<C-r>+", { noremap = true, desc = "Paste from clipboard in insert mode" })
  keymap("n", "<Leader>V", '"+p', { noremap = true, desc = "Clean paste from clipboard" })

  -- Enhanced format-preserving paste
  keymap("n", "<Leader>fp", function()
    -- Save cursor position
    local cursor_pos = vim.fn.getcurpos()

    -- Save various options that affect pasting
    local old_autoindent = vim.opt.autoindent:get()
    local old_smartindent = vim.opt.smartindent:get()
    local old_cindent = vim.opt.cindent:get()
    local old_fo = vim.opt.formatoptions:get()

    -- Configure for optimal pasting
    vim.opt.autoindent = false
    vim.opt.smartindent = false
    vim.opt.cindent = false
    vim.opt.paste = true

    -- Perform the paste operation
    vim.cmd 'normal! "+p'

    -- Restore all settings
    vim.opt.autoindent = old_autoindent
    vim.opt.smartindent = old_smartindent
    vim.opt.cindent = old_cindent
    vim.opt.formatoptions = old_fo
    vim.opt.paste = false

    -- Restore cursor position
    vim.fn.setpos(".", cursor_pos)
  end, { noremap = true, desc = "Enhanced format-preserving paste" })

  -- Add visual mode version of format-preserving paste
  keymap("v", "<Leader>fp", function()
    -- Save options
    local old_autoindent = vim.opt.autoindent:get()
    local old_smartindent = vim.opt.smartindent:get()

    -- Configure for pasting
    vim.opt.autoindent = false
    vim.opt.smartindent = false
    vim.opt.paste = true

    -- Delete selection and paste
    vim.cmd 'normal! "_d"+P'

    -- Restore settings
    vim.opt.autoindent = old_autoindent
    vim.opt.smartindent = old_smartindent
    vim.opt.paste = false
  end, { noremap = true, desc = "Visual enhanced format-preserving paste" })

  -- JQ Keybindings
  keymap("n", "<Leader>fj", "<Cmd>%!jq<CR>", opts) -- Format entire buffer
  keymap("n", "<Leader>fcj", "<Cmd>%!jq --compact-output<CR>", opts) -- Minify entire buffer
  keymap("v", "<Leader>fj", ":'<,'>!jq<CR>", opts) -- Format selection
  keymap("v", "<Leader>fcj", ":'<,'>!jq --compact-output<CR>", opts) -- Minify selection

  -- Main telescope functions
  keymap("n", "<Leader>tf", "<cmd>Telescope find_files<CR>", opts) -- Find files
  keymap("n", "<Leader>tg", "<cmd>Telescope live_grep<CR>", opts) -- Find text in files
  keymap("n", "<Leader>tb", "<cmd>Telescope buffers<CR>", opts) -- Find open buffers
  keymap("n", "<Leader>th", "<cmd>Telescope help_tags<CR>", opts) -- Find help tags
  keymap("n", "<Leader>tR", "<cmd>Telescope oldfiles<CR>", opts) -- Find recent files
  keymap("n", "<Leader>tc", "<cmd>Telescope colorscheme<CR>", opts) -- Find colorschemes

  -- Project management - changed to tP to avoid conflict with paste toggle
  keymap("n", "<Leader>tP", "<cmd>Telescope project<CR>", opts) -- Find projects

  -- File browser
  keymap("n", "<Leader>te", "<cmd>Telescope file_browser<CR>", opts) -- File explorer

  -- NeoTree file explorer mappings
  keymap("n", "<leader>e", ":Neotree toggle<CR>", opts) -- Toggle NeoTree
  keymap("n", "<leader>o", ":Neotree focus<CR>", opts)

  -- LSP related
  keymap("n", "<Leader>ts", "<cmd>Telescope lsp_document_symbols<CR>", opts) -- Document symbols
  keymap("n", "<Leader>tS", "<cmd>Telescope lsp_workspace_symbols<CR>", opts) -- Workspace symbols
  keymap("n", "<Leader>td", "<cmd>Telescope lsp_definitions<CR>", opts) -- Go to definition
  keymap("n", "<Leader>tt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- Go to type definition
  keymap("n", "<Leader>tr", "<cmd>Telescope lsp_references<CR>", opts) -- Find references
  keymap("n", "<Leader>ti", "<cmd>Telescope lsp_implementations<CR>", opts) -- Find implementations

  -- Git operations
  keymap("n", "<Leader>gc", "<cmd>Telescope git_commits<CR>", opts) -- Git commits
  keymap("n", "<Leader>gb", "<cmd>Telescope git_branches<CR>", opts) -- Git branches
  keymap("n", "<Leader>gs", "<cmd>Telescope git_status<CR>", opts) -- Git status

  -- LSP Format keybinding
  keymap("n", "<Leader>ff", "<cmd>lua vim.lsp.buf.format()<CR>", opts)

  -- Custom Telescope functions
  -- Find Python files only
  keymap("n", "<Leader>py", "<cmd>Telescope find_files find_command=find,.,'-name','*.py'<CR>", opts)

  -- Find Ansible YAML files
  keymap(
    "n",
    "<Leader>ya",
    "<cmd>Telescope find_files find_command=find,.,'-name','*.yml','-o','-name','*.yaml'<CR>",
    opts
  )

  -- Find JSON files
  keymap("n", "<Leader>js", "<cmd>Telescope find_files find_command=find,.,'-name','*.json'<CR>", opts)

  -- Find TODOs
  keymap("n", "<Leader>to", "<cmd>Telescope grep_string search='TODO\\|FIXME\\|BUG\\|HACK\\|NOTE'<CR>", opts)
end
