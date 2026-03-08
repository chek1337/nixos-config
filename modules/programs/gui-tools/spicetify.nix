{ inputs, ... }:
{
  flake.modules.homeManager.spicetify =
    { pkgs, ... }:
    {
      imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];
      programs.spicetify = {
        enable = true;
      };
    };
}
