{
  # Весь трафик через локальный mixed-порт v2rayN (маршрутизация direct/proxy
  # решается его routing-правилами). content.proxy = "system" тут бесполезен:
  # v2rayN на Linux выставляет системный прокси только в gsettings/KDE, а под
  # niri их никто не читает.
  flake.modules.homeManager.qutebrowser-proxy = {
    programs.qutebrowser.settings.content.proxy = "socks5://127.0.0.1:10808";
  };
}
