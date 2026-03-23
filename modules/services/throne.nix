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
    { pkgs, ... }:
    {
      # programs.zsh.shellAliases = {
      #   throne = "${pkgs.throne}/bin/Throne";
      # };
      # xdg.desktopEntries = {
      #   throne = {
      #     name = "Throne";
      #     exec = "${pkgs.throne}/bin/Throne";
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
