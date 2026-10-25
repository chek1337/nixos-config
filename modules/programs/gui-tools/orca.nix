{
  # Orca (https://www.onorca.dev) — ADE для параллельной работы coding-агентов.
  # В nixpkgs нет. AppImage намеренно живёт вне /nix/store, в ~/Applications:
  # appimage-run экспортирует APPIMAGE, и встроенный апдейтер Orca сам
  # подменяет файл новой версией, как на обычных дистрибутивах.
  flake.modules.homeManager.orca =
    { pkgs, ... }:
    let
      icon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/stablyai/orca/v1.4.240/resources/build/icon.png";
        hash = "sha256-M6r7Kdr+K3vuPKcdAC8YIbvpIK5FpWQ8J/ud3tN8EuY=";
      };
      orca = pkgs.writeShellApplication {
        name = "orca-ide";
        runtimeInputs = with pkgs; [
          appimage-run
          curl
        ];
        text = ''
          appimage="$HOME/Applications/orca-linux.AppImage"

          # Первый запуск на новой машине: скачиваем последнюю версию.
          if [ ! -e "$appimage" ]; then
            mkdir -p "$(dirname "$appimage")"
            curl -fL --output "$appimage.part" \
              https://github.com/stablyai/orca/releases/latest/download/orca-linux.AppImage
            chmod +x "$appimage.part"
            mv "$appimage.part" "$appimage"
          fi

          exec appimage-run "$appimage" "$@"
        '';
      };
    in
    {
      home.packages = [ orca ];

      # Не перехватываем markdown/csv у остальных программ, оставляем только orca://.
      xdg.desktopEntries.orca-ide = {
        name = "Orca";
        comment = "Next-gen IDE for parallel agentic development";
        exec = "orca-ide %U";
        icon = "${icon}";
        categories = [ "Utility" ];
        mimeType = [ "x-scheme-handler/orca" ];
        settings.StartupWMClass = "orca";
      };
    };
}
