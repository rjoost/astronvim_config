-- SRE/DevOps tooling: schema validation, linting, test runner
---@type LazySpec
return {

  -- SchemaStore: 500+ JSON/YAML schemas (K8s, Ansible, docker-compose, GitHub Actions...)
  -- NOT lazy = true: astrolsp.lua calls require("schemastore") at spec-parse time (in the
  -- config table, not inside a function). SchemaStore must be in memory by then.
  -- It's a pure Lua data library with negligible startup cost.
  {
    "b0o/SchemaStore.nvim",
  },

  -- nvim-lint: run linters on file save (separate from LSP diagnostics)
  {
    "mfussenegger/nvim-lint",
    event = "BufReadPost", -- loads the plugin; the autocmd below handles actual linting
    config = function()
      local lint = require "lint"

      lint.linters_by_ft = {
        yaml             = { "yamllint" },
        ["yaml.ansible"] = { "ansible-lint" }, -- Ansible yaml only, not generic yaml
        sh               = { "shellcheck" },
        bash             = { "shellcheck" },
        python           = { "ruff" },
      }

      -- autocmd fires linting; plugin-level event above just triggers load
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- neotest: run pytest/Molecule tests inline with pass/fail decorations
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",           -- required async library
      "nvim-lua/plenary.nvim",           -- already in AstroNvim
      "antoinemadec/FixCursorHold.nvim", -- required performance fix
      "nvim-treesitter/nvim-treesitter", -- already in AstroNvim
      "nvim-neotest/neotest-python",     -- Python/pytest adapter
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require("neotest-python") {
            python = function()
              -- Use active venv if venv-selector has one, else fall back
              local venv = os.getenv "VIRTUAL_ENV"
              if venv then return venv .. "/bin/python" end
              return vim.g.python3_host_prog or "python3"
            end,
            runner = "pytest",
            args = { "--no-header", "-rN", "--tb=short" },
          },
        },
        output_panel = { enabled = true },
        summary = { enabled = true },
      }
    end,
  },
}
