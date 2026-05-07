{ ... }:
{
  flake.modules.homeManager.gemini-cli =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gemini-cli ];
    };
}
