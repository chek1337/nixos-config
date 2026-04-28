{ inputs, ... }:
{
  flake.modules.homeManager.hibiki =
    { pkgs-unstable, ... }:
    {
      home.packages = [ inputs.hibiki.packages.${pkgs-unstable.stdenv.hostPlatform.system}.default ];
    };
}
