{ ... }:
{
  flake.modules.homeManager.bat =
    { pkgs-stable, ... }:
    {
      programs.bat = {
        enable = true;
        extraPackages = with pkgs-stable.bat-extras; [
          batdiff
          batman
          batgrep
          batwatch
        ];
      };
      home.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | env TERM=xterm-256color bat -l man -p'";
        MANROFFOPT = "-c";
      };
    };
}
