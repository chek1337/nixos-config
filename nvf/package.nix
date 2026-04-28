{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      nvimPkg =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [
            { _module.args.colorScheme = "nord"; }
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
