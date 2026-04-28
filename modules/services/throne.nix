{ ... }:
{
  flake.modules.nixos.throne =
    { ... }:
    {
      programs.throne = {
        enable = true;
        tunMode.enable = true;
      };
    };

  flake.modules.homeManager.throne =
    { pkgs-stable, ... }:
    {
      # programs.zsh.shellAliases = {
      #   throne = "${pkgs-stable.throne}/bin/Throne";
      # };
      # xdg.desktopEntries = {
      #   throne = {
      #     name = "Throne";
      #     exec = "${pkgs-stable.throne}/bin/Throne";
      #     icon = "throne";
      #     comment = "Throne proxy manager (sing-box)";
      #     categories = [
      #       "Network"
      #       "Utility"
      #     ];
      #   };
      # };
    };
}
