{
  # GUI-клиент AmneziaVPN со split-tunneling (по сайтам/IP).
  # Привилегированный демон AmneziaVPN-service поднимается systemd-сервисом
  # из самого пакета; GUI (AmneziaVPN) общается с ним по локальному сокету.
  # Userspace-бэкенды (amneziawg-go / openvpn / tun2socks / wg-quick) вшиты
  # в пакет, kernel-модуль amneziawg для этого не нужен.
  flake.modules.nixos.amnezia-vpn =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.amnezia-vpn ];

      # Юнит AmneziaVPN.service лежит в пакете (lib/systemd/system/);
      # регистрируем его и включаем автозапуск root-демона, без которого
      # GUI не может поднять туннель.
      systemd.packages = [ pkgs.amnezia-vpn ];
      systemd.services.AmneziaVPN.wantedBy = [ "multi-user.target" ];
    };
}
