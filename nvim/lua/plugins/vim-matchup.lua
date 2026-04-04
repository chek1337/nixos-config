-- lua/plugins/matchup.lua    или просто в любом файле plugins/
return {
  "andymass/vim-matchup",

  config = function()
    local function apply()
      local scheme = vim.g.colors_name or ""
      local color = scheme:find("catppuccin") and "#fab387"
                 or scheme == "gruvbox" and "#fe8019"
                 or "#d08770" -- nord + fallback
      vim.api.nvim_set_hl(0, "MatchWord", { fg = color })
      vim.api.nvim_set_hl(0, "MatchWordCur", { fg = color })
    end
    apply()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
  end,
}
