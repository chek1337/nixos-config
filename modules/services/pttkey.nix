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

      # To find the key name for pttkey:
      #   sudo evtest → select device → press desired key → look for "code" field
      #   Example output: "Event: ... code 276 (BTN_EXTRA), value 1"
      #   Use the name in parentheses (e.g. BTN_EXTRA, KEY_F9, BTN_SIDE)
      #
      # Common key names:
      #   BTN_EXTRA (Mouse5), BTN_SIDE (Mouse4)
      #   KEY_PAUSE, KEY_SCROLLLOCK, KEY_F13..KEY_F24
      xdg.configFile."pttkey/config.toml".text = ''
        keys = ["KEY_V"]
        mode = "mute"
      '';

      systemd.user.services.pttkey = {
        Unit = {
          Description = "Push-to-talk mic toggle (pttkey)";
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
        };
        # TODO: enable autostart after debugging
        # Install.WantedBy = [ "graphical-session.target" ];
      };

      programs.zsh.shellAliases = {
        ptt-up = "systemctl --user start pttkey.service";
        ptt-down = "systemctl --user stop pttkey.service";
        ptt-status = "systemctl --user status pttkey.service";
        ptt-log = "journalctl --user -u pttkey.service -f";
      };
    };
}
