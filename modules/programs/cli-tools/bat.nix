{ ... }:
{
  flake.modules.homeManager.bat =
    { pkgs, ... }:
    {
      programs.bat = {
        enable = true;
        config = {
          pager = "env TERM=xterm-256color less -FR";
        };
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          batgrep
          batwatch
        ];
      };
      home.sessionVariables = {
        PAGER = "env TERM=xterm-256color bat --paging=always";
        MANPAGER = "sh -c 'col -bx | env TERM=xterm-256color bat -l man -p'";
        MANROFFOPT = "-c";
      };
    };
}
