{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      nvimPkg =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [
            ./options.nix
            ./keymaps.nix
            ./lsp.nix
            ./plugins
          ];
        }).neovim;
    in
    {
      packages.nvim = nvimPkg;
      apps.nvim = {
        type = "app";
        program = "${nvimPkg}/bin/nvim";
      };
    };
}
