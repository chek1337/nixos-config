{ inputs, ... }:
{
  flake.modules.homeManager.kimi-code =
    { pkgs, ... }:
    {
      home.packages = [ inputs.kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.kimi-code ];
    };
}
