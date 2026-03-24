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
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.services.pttkey;

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

      # Generate config.toml content for a binding
      mkConfig =
        binding:
        ''
          keys = [${lib.concatMapStringsSep ", " (k: ''"${k}"'') binding.keys}]
          mode = "mute"
          sounds = false''
        + lib.optionalString (binding.devicePath != null) ''

          device_path = "${binding.devicePath}"'';

      # Generate a systemd user service for a binding
      mkService = name: _binding: {
        Unit = {
          Description = "Push-to-talk: ${name} (pttkey)";
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
          Environment = "XDG_CONFIG_HOME=%h/.config/pttkey-${name}";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      serviceNames = lib.mapAttrsToList (name: _: "pttkey-${name}.service") cfg.bindings;
    in
    {
      options.services.pttkey.bindings = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              keys = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Key names to use as PTT trigger (e.g. BTN_EXTRA, KEY_F13)";
              };
              devicePath = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Evdev device path (null = auto-detect)";
              };
            };
          }
        );
        default = { };
        description = ''
          PTT key bindings. Each entry creates a config and systemd service.
          To find key names: sudo evtest → select device → press key → "code" field
          To find device_path: ls -la /dev/input/by-id/ | grep mouse
        '';
      };

      config = lib.mkIf (cfg.bindings != { }) {
        home.packages = [
          pttkey
          pkgs.evtest
          pkgs.pavucontrol
        ];

        xdg.configFile = lib.mapAttrs' (
          name: binding:
          lib.nameValuePair "pttkey-${name}/pttkey/config.toml" {
            text = mkConfig binding;
          }
        ) cfg.bindings;

        systemd.user.services = lib.mapAttrs' (
          name: binding: lib.nameValuePair "pttkey-${name}" (mkService name binding)
        ) cfg.bindings;

        programs.zsh.shellAliases = {
          ptt-up = "systemctl --user start ${lib.concatStringsSep " " serviceNames}";
          ptt-down = "systemctl --user stop ${lib.concatStringsSep " " serviceNames}";
          ptt-status = "systemctl --user status ${lib.concatStringsSep " " serviceNames}";
          ptt-log = "journalctl --user -u 'pttkey-*' -f";
        };
      };
    };
}
