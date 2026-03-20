{ inputs, ... }:
{
  flake.modules.nixos.pttkey =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      users.users.${username}.extraGroups = [ "input" ];
    };

  flake.modules.homeManager.pttkey =
    { pkgs, lib, ... }:
    let
      pttkey = pkgs.rustPlatform.buildRustPackage {
        pname = "pttkey";
        version = "0.2.6";
        src = inputs.pttkey;
        cargoHash = "sha256-aB2BX3apofRBFGHxB8LpUYKCHxyQwHEKmmgeIKC8A+w=";

        nativeBuildInputs = with pkgs; [
          pkg-config
          makeWrapper
        ];
        buildInputs = [ pkgs.alsa-lib ];

        postInstall = ''
          wrapProgram $out/bin/pttkey \
            --suffix PATH : ${lib.makeBinPath [ pkgs.wireplumber ]}
        '';

        meta = {
          description = "Linux push-to-talk for PipeWire via evdev";
          homepage = "https://github.com/Wuild/pttkey";
          license = lib.licenses.mit;
          mainProgram = "pttkey";
        };
      };
    in
    {
      home.packages = [
        pttkey
        pkgs.evtest
        pkgs.pavucontrol
      ];

      # Two pttkey daemons: mouse (BTN_EXTRA) and keyboard (KEY_F13),
      # so PTT works regardless of which hand is free.
      # Each gets its own XDG_CONFIG_HOME to isolate config.toml.
      #
      # To find key names: sudo evtest → select device → press key → "code" field
      # To find device_path: ls -la /dev/input/by-id/ | grep mouse
      xdg.configFile."pttkey-mouse/pttkey/config.toml".text = ''
        keys = ["BTN_EXTRA"]
        mode = "mute"
        device_path = "/dev/input/by-id/usb-E-Signal_USB_Gaming_Mouse-event-mouse"
      '';

      xdg.configFile."pttkey-kbd/pttkey/config.toml".text = ''
        keys = ["KEY_F13"]
        mode = "mute"
      '';

      systemd.user.services.pttkey-mouse = {
        Unit = {
          Description = "Push-to-talk via mouse (pttkey)";
          After = [
            "pipewire.service"
            "graphical-session.target"
          ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${lib.meta.getExe pttkey}";
          Restart = "on-failure";
          RestartSec = 3;
          Environment = "XDG_CONFIG_HOME=%h/.config/pttkey-mouse";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      systemd.user.services.pttkey-kbd = {
        Unit = {
          Description = "Push-to-talk via keyboard (pttkey)";
          After = [
            "pipewire.service"
            "graphical-session.target"
          ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${lib.meta.getExe pttkey}";
          Restart = "on-failure";
          RestartSec = 3;
          Environment = "XDG_CONFIG_HOME=%h/.config/pttkey-kbd";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      programs.zsh.shellAliases = {
        ptt-up = "systemctl --user start pttkey-mouse.service pttkey-kbd.service";
        ptt-down = "systemctl --user stop pttkey-mouse.service pttkey-kbd.service";
        ptt-status = "systemctl --user status pttkey-mouse.service pttkey-kbd.service";
        ptt-log = "journalctl --user -u 'pttkey-*' -f";
      };
    };
}
