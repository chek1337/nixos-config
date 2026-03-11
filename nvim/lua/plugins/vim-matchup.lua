-- lua/plugins/matchup.lua    или просто в любом файле plugins/
return {
  "andymass/vim-matchup",

  config = function()
    vim.api.nvim_set_hl(0, "MatchWord", { fg = "#d08770" })
    vim.api.nvim_set_hl(0, "MatchWordCur", { fg = "#d08770" })
  end,
}
