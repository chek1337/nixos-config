{ lib, ... }:
{
  flake.modules.homeManager.eltex-proxy-aliases = {
    programs.zsh.initContent = lib.mkAfter ''
      eltex-proxy-up() {
        sudo -v || return 1
        sudo mkdir -p /run/systemd/system/nix-daemon.service.d
        {
          echo '[Service]'
          echo 'Environment="http_proxy=http://proxy.eltex.loc:3128"'
          echo 'Environment="https_proxy=http://proxy.eltex.loc:3128"'
          echo 'Environment="no_proxy=127.0.0.1,localhost,.eltex.loc"'
        } | sudo tee /run/systemd/system/nix-daemon.service.d/00-eltex-proxy.conf >/dev/null
        sudo systemctl daemon-reload
        sudo systemctl restart nix-daemon
        echo "nix-daemon now uses http://proxy.eltex.loc:3128 (runtime drop-in)"
      }

      eltex-proxy-down() {
        sudo -v || return 1
        sudo rm -f /run/systemd/system/nix-daemon.service.d/00-eltex-proxy.conf
        sudo systemctl daemon-reload
        sudo systemctl restart nix-daemon
        echo "Runtime proxy override removed."
      }
    '';
  };
}
