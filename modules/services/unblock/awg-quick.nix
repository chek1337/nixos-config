{ lib, ... }:
{
  flake.modules.nixos.awg-quick =
    { config, pkgs, ... }:
    let
      configs = config.settings.amneziaWgExtraConfigs;
      svcName = name: "awg-quick-${name}";
      # Linux IFNAMSIZ caps interface names at 15 chars. Keep the suffix
      # since it's usually what distinguishes configs (e.g. -2, -3).
      ifaceName =
        name:
        let
          n = lib.stringLength name;
        in
        if n <= 15 then name else lib.substring (n - 15) 15 name;
      confPath = name: "/etc/amnezia/amneziawg/${ifaceName name}.conf";
    in
    lib.mkIf (configs != [ ]) {
      systemd.tmpfiles.rules = [
        "d /etc/amnezia 0755 root root -"
        "d /etc/amnezia/amneziawg 0700 root root -"
      ]
      ++ map (name: "L+ ${confPath name} - - - - /run/secrets/${name}") configs;

      environment.systemPackages = [ pkgs.amneziawg-tools ];

      systemd.services = lib.listToAttrs (
        map (name: {
          name = svcName name;
          value = {
            description = "AmneziaWG tunnel (${name})";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            path = with pkgs; [
              amneziawg-tools
              iproute2
            ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "${pkgs.amneziawg-tools}/bin/awg-quick up ${confPath name}";
              ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down ${confPath name}";
            };
          };
        }) configs
      );

      security.sudo.extraRules = [
        {
          users = [ config.settings.username ];
          commands = lib.flatten (
            map (
              name:
              map
                (action: {
                  command = "${pkgs.systemd}/bin/systemctl ${action} ${svcName name}.service";
                  options = [ "NOPASSWD" ];
                })
                [
                  "start"
                  "stop"
                  "restart"
                ]
            ) configs
          );
        }
      ];
    };

  flake.modules.homeManager.awg-quick =
    { config, ... }:
    let
      configs = config.settings.amneziaWgExtraConfigs;
    in
    lib.mkIf (configs != [ ]) {
      programs.zsh.initContent = ''
        awg-up()      { sudo systemctl start   awg-quick-"$1".service; }
        awg-down()    { sudo systemctl stop    awg-quick-"$1".service; }
        awg-restart() { sudo systemctl restart awg-quick-"$1".service; }
        awg-status()  { systemctl status       awg-quick-"$1".service; }
        awg-list()    { systemctl list-units 'awg-quick-*.service' --all; }
      '';
    };
}
