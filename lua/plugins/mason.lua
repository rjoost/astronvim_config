---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "ansiblels",   -- Ansible language server
      },
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "ruff",         -- Python linter binary (used by nvim-lint, NOT none-ls)
        "yamllint",     -- YAML linting
        "ansible-lint", -- Ansible linting
        -- shellcheck: installed by astrocommunity.pack.sh automatically
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "python",
      },
    },
  },
}
