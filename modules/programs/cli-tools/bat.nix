{ ... }:
{
  flake.modules.homeManager.bat =
    { ... }:
    {
      programs.bat = {
        enable = true;
        config = {
          pager = "less -RF";
        };
      };

      home.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      };
    };
}
