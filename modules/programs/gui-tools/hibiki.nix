{ inputs, ... }:
{
  flake.modules.homeManager.hibiki =
    { pkgs, ... }:
    {
      home.packages = [ inputs.hibiki.packages.${pkgs.system}.default ];
    };
}
