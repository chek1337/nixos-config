{ ... }:
{
  flake.modules.homeManager.zmkbatx =
    { pkgs-stable, lib, ... }:
    {
      home.packages = [ pkgs-stable.zmkbatx ];

      systemd.user.services.zmkbatx = {
        Unit = {
          Description = "zmkBATx BLE keyboard battery monitor";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = ''
            ${pkgs-stable.runtimeShell} -l -c "${lib.meta.getExe' pkgs-stable.busybox "sleep"} 5 && ${lib.meta.getExe' pkgs-stable.zmkbatx "zmkBATx"}"
          '';
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      programs.zsh.shellAliases = {
        zmkbatx-up = "systemctl --user start zmkbatx.service";
        zmkbatx-down = "systemctl --user stop zmkbatx.service";
        zmkbatx-status = "systemctl --user status zmkbatx.service";
      };
    };
}
