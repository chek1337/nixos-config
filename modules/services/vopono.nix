{ ... }:
{
  flake.modules.nixos.vopono =
    {
      config,
      pkgs,
      ...
    }:
    {
      assertions = [
        {
          assertion = config.sops.secrets ? wireguard;
          message = "flake.modules.nixos.vopono требует flake.modules.nixos.wireguard (sops secret 'wireguard')";
        }
      ];

      environment.systemPackages = with pkgs; [
        vopono
        wireguard-tools
        iptables
      ];

      systemd.services.vopono = {
        enable = true;
        description = "Vopono daemon";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.vopono}/bin/vopono daemon";
          Restart = "on-failure";
          RestartSec = "5s";
          Environment = "RUST_LOG=debug";
        };
      };

      security.sudo.extraRules = [
        {
          users = [ "chek" ];
          commands = [
            {
              command = "${pkgs.vopono}/bin/vopono *";
              # SETENV оставляем, на случай если sudo сам сбросит нужное
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
        }
      ];
    };

  flake.modules.homeManager.vopono =
    { osConfig, pkgs, ... }:
    let
      wgConf = osConfig.sops.secrets.wireguard.path;
      voponoExe = "${pkgs.vopono}/bin/vopono";
      quteExe = "${pkgs.qutebrowser}/bin/qutebrowser";

      debugLaunchScript = pkgs.writeShellScript "vopono-debug-launch" ''
        LOG_FILE="$HOME/vopono-debug.log"

        echo "=== Запуск Vopono Debug: $(date) ===" > "$LOG_FILE"
        echo "[INFO] User: $(whoami)" >> "$LOG_FILE"
        echo "[INFO] UID: $(id -u)" >> "$LOG_FILE"

        echo "[INFO] Environment Variables Check:" >> "$LOG_FILE"
        env | grep -E "(WAYLAND|DISPLAY|XDG_RUNTIME|DBUS)" >> "$LOG_FILE" || echo "[WARN] Нет графических переменных окружения!" >> "$LOG_FILE"

        echo "[INFO] Executing: ${voponoExe} exec --protocol wireguard --custom ${wgConf} ${quteExe}" >> "$LOG_FILE"

        # Запуск
        ${voponoExe} exec --protocol wireguard --custom ${wgConf} ${quteExe} >> "$LOG_FILE" 2>&1

        EXIT_CODE=$?
        echo "[INFO] Exited with code: $EXIT_CODE" >> "$LOG_FILE"
      '';

    in
    {
      programs.zsh.shellAliases = {
        vopono-up = "sudo systemctl start vopono.service";
        vopono-down = "sudo systemctl stop vopono.service";
        vopono-status = "sudo systemctl status vopono.service";
        vopono-logs = "sudo journalctl -u vopono -e";
        vopono-debug = "cat $HOME/vopono-debug.log";
      };

      xdg.desktopEntries.qutebrowser-vpn = {
        name = "Qutebrowser (VPN)";
        comment = "Launch Qutebrowser through Vopono";
        # Чистый запуск через sudo
        exec = "sudo ${debugLaunchScript}";
        icon = "qutebrowser";
        terminal = false;
        type = "Application";
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeType = [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
      };
    };
}
