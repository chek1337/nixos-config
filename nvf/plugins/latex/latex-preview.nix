{ pkgs, lib, ... }:
let
  # mathjax-full@3 is not in nixpkgs; it's a pure-JS package with no deps,
  # so we just unpack the npm tarball — no npm install needed.
  mathjax-full = pkgs.runCommand "mathjax-full-3.2.2" { } ''
    mkdir -p $out
    tar xf ${pkgs.fetchurl {
      url = "https://registry.npmjs.org/mathjax-full/-/mathjax-full-3.2.2.tgz";
      hash = "sha256-2PCA0uS9+3UoSqw01e/xVQAuykd5ix1OS94xRT5lP4c=";
    }} --strip-components=1 -C $out
  '';

  latex-preview-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "latex-preview-nvim";
    version = "2026-05-05";
    src = pkgs.fetchFromGitHub {
      owner = "sonv";
      repo = "latex-preview.nvim";
      rev = "779536fcf8ec1c801eb1491cc5ac6e98214ede93";
      hash = "sha256-0zBd7NOwiZIvFEH/IJm/Usj+PJU/meakW/ShgWPGzSM=";
    };
  };
in
{
  vim.extraPackages = [
    pkgs.nodejs
    pkgs.librsvg
  ];

  # Enable snacks image support (required by latex-preview.nvim)
  vim.utility.snacks-nvim.setupOpts.image.enabled = true;

  vim.extraPlugins = {
    latex-preview-nvim = {
      package = latex-preview-nvim;
      setup = # lua
        ''
          vim.env.LATEX_PREVIEW_MATHJAX_PATH = "${mathjax-full}"

          require("latex-preview").setup({
            setup_keymap = true,
            keymap = "<leader>ih",
            cache = true,
            cache_dir = "aux",
            render = {
              density = 300,
              svg_to_png = "auto",
            },
          })
        '';
    };
  };
}
