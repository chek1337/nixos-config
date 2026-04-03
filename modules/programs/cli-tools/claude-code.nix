{ inputs, ... }:
{
  flake.modules.homeManager.claude-code =
    { pkgs, ... }:
    {
      home.packages = [ inputs.claude-code-nix.packages.${pkgs.system}.claude-code ];
    };
}
