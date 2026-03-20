{
  flake.modules.homeManager.zathura =
    { pkgs, ... }:
    {
      programs.zathura.enable = true;

      xdg.mimeApps.defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
    };
}
