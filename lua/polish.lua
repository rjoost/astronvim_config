-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

return function()
  -- Global Variables
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Load essential plugins immediately
  local plugins_to_load = {
    "jq.nvim",
    "neo-tree.nvim",
    "nvim-colorizer.lua",
    "plenary.nvim",
    "todo-comments.nvim"
  }

  for _, plugin in ipairs(plugins_to_load) do
    require("lazy").load({ plugins = { plugin } })
  end

  -- Editor Options
  local opt = vim.opt
  opt.clipboard = "unnamedplus"   -- Use system clipboard
  opt.number = false              -- No line numbers
  opt.relativenumber = false      -- No relative line numbers
  opt.tabstop = 2                -- Number of spaces for tab
  opt.shiftwidth = 2             -- Number of spaces for autoindent
  opt.expandtab = true           -- Convert tabs to spaces
  opt.termguicolors = true       -- True color support

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
            "gitsigns.nvim",
            "jq.nvim",
            "lazydev.nvim",
            "neo-tree.nvim",
            "nvim-colorizer.lua",
            "plenary.nvim",
            "todo-comments.nvim",
          }
        })
      end)
    end,
    desc = "Load essential plugins early",
  })

  -- JQ Configuration
  local opts = { noremap = true, silent = true }

  -- JQ Keybindings
  local keymap = vim.keymap.set
  keymap("n", "<Leader>fj", "<Cmd>%!jq<CR>", opts)                    -- Format entire buffer
  keymap("n", "<Leader>fcj", "<Cmd>%!jq --compact-output<CR>", opts) -- Minify entire buffer
  keymap("v", "<Leader>fj", ":'<,'>!jq<CR>", opts)                   -- Format selection
  keymap("v", "<Leader>fcj", ":'<,'>!jq --compact-output<CR>", opts) -- Minify selection

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
end
