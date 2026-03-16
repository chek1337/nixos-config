{ ... }:
{
  flake.modules.homeManager.claude-code =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.claude-code ];
    };
}
