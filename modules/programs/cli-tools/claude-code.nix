{ inputs, ... }:
{
  flake.modules.homeManager.claude-code =
    { pkgs-unstable, ... }:
    {
      home.packages = [
        inputs.claude-code-nix.packages.${pkgs-unstable.stdenv.hostPlatform.system}.claude-code
      ];
    };
}
