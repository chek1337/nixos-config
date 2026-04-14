{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      nvimPkg =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [
            { _module.args.colorScheme = ""; }
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
