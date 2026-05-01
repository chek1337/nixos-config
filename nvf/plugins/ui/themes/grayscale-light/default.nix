{ pkgs }:
let
  monochrome-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "monochrome.nvim";
    version = "unstable-2021-07-14";
    src = pkgs.fetchFromGitHub {
      owner = "kdheepak";
      repo = "monochrome.nvim";
      rev = "2de78d9688ea4a177bcd9be554ab9192337d35ff";
      hash = "sha256-TgilR5jnos2YZeaJUuej35bQ9yE825MQk0s6gxwkAbA=";
    };
  };
in
{
  package = monochrome-nvim;

  setup = # lua
    ''
      vim.g.monochrome_style = "default"
      vim.o.background = "light"
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "monochrome",
        callback = function()
          vim.api.nvim_set_hl(0, "SnacksIndent", { link = "NonText" })
          vim.api.nvim_set_hl(0, "SnacksIndentScope", { link = "LineNr" })
          vim.api.nvim_set_hl(0, "SnacksIndentChunk", { link = "LineNr" })
          for i = 1, 8 do
            vim.api.nvim_set_hl(0, "SnacksIndent" .. i, { link = "NonText" })
          end
        end,
      })
      vim.cmd.colorscheme("monochrome")
    '';
}
