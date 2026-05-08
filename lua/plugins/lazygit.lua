-- lazygit inside nvim
---@type LazySpec
return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- keys trigger lazy-load — this is the correct pattern for kdheepak/lazygit.nvim
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open Lazygit" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
