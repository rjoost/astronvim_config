-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    -- joost for mac mini m4 pro, 48gb memory
    features = {
      large_buf = { size = 1024 * 1024 * 2, lines = 50000 }, -- 2MB / 50k lines: disable treesitter etc. on large files
      autopairs = false, -- disable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3,  -- 3 = fully on
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false,
        number = false,
        spell = false,
        signcolumn = "yes",
        wrap = true,
        ignorecase = true,
        hlsearch = false,
        breakindent = true,
        tabstop = 2,
        shiftwidth = 2,
        expandtab = true,
        guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20",
        cursorline = true,
        termguicolors = true,
        list = true,
        listchars = "tab:▸·,trail:·,nbsp:·",
        scrolloff = 8,
        incsearch = true,
        smartcase = true,
        wildmenu = true,
        wildoptions = "pum",
        jumpoptions = "stack",
        formatoptions = "tcqrn1",
        clipboard = "unnamedplus",
        completeopt = "menu,menuone,noselect",
        lazyredraw = false,  -- noice.nvim breaks with lazyredraw=true
        updatetime = 300,
        cmdheight = 0,  -- noice.nvim uses a float
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- Neotest
        ["<Leader>nn"] = { function() require("neotest").run.run() end, desc = "Run nearest test" },
        ["<Leader>nf"] = { function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Run all tests in file" },
        ["<Leader>no"] = { function() require("neotest").output_panel.toggle() end, desc = "Toggle test output panel" },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
    },
  },
}
