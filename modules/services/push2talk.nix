{ inputs, ... }:
{
  flake.modules.nixos.push2talk =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      users.users.${username}.extraGroups = [ "input" ];
    };

  flake.modules.homeManager.push2talk =
    { pkgs, lib, ... }:
    let
      push2talk = inputs.push2talk.packages.${pkgs.system}.default;
    in
    {
      home.packages = [ push2talk ];

      # Config via environment file: ~/.config/push2talk/service.conf
      # Available env vars:
      #   PUSH2TALK_KEYBIND — key combo (default: Control_Left+Space)
      #   PUSH2TALK_SOURCE  — audio source name (default: all mics)
      xdg.configFile."push2talk/service.conf".text = ''
        PUSH2TALK_KEYBIND=Control_Left+space
      '';

      systemd.user.services.push2talk = {
        Unit = {
          Description = "Push to talk";
          After = [
            "pipewire-pulse.service"
            "graphical-session.target"
          ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${lib.meta.getExe push2talk}";
          EnvironmentFile = "%h/.config/push2talk/service.conf";
          Restart = "always";
          RestartSec = 10;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      programs.zsh.shellAliases = {
        p2t-up = "systemctl --user start push2talk.service";
        p2t-down = "systemctl --user stop push2talk.service";
        p2t-status = "systemctl --user status push2talk.service";
        p2t-log = "journalctl --user -u push2talk.service -f";
      };
    };
}
