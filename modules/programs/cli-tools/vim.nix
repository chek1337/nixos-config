{ ... }:
{
  flake.modules.homeManager.vim =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.vim ];
    };
}
