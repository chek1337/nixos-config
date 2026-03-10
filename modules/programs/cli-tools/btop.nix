{ ... }:
{
  flake.modules.homeManager.btop =
    { ... }:
    {
      programs.btop = {
        enable = true;
        settings = {
          vim_keys = true;
          rounded_corners = true;
          update_ms = 500;
        };
      };
    };
}
