---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "catppuccin",
    highlights = {
      init = {
        Comment = { italic = true },
        TodoBgTODO = { fg = "#000000", bg = "#FFBD2A", bold = true },
        TodoBgFIX  = { fg = "#000000", bg = "#FF5370", bold = true },
        TodoBgHACK = { fg = "#000000", bg = "#C792EA", bold = true },
        TodoBgNOTE = { fg = "#000000", bg = "#7DCFFF", bold = true },
      },
    },
  },
}
