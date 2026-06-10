# Портативный vopono для не-NixOS хостов (Ubuntu): без sops и без демона,
# путь к wireguard-конфигу передаётся аргументом в runtime.
{
  flake.modules.homeManager.vopono-portable =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vopono
        wireguard-tools
      ];

      programs.zsh.initContent = ''
        # vopono требует root для создания network namespace
        vopono-file() {
          local cfg="$1"; shift
          sudo -E ${pkgs.vopono}/bin/vopono exec --custom "$cfg" --protocol wireguard "$@"
        }
      '';
    };
}
