{
  # Orca (https://www.onorca.dev) — ADE для параллельной работы coding-агентов.
  # В nixpkgs нет. AppImage намеренно живёт вне /nix/store, в ~/Applications:
  # appimage-run экспортирует APPIMAGE, и встроенный апдейтер Orca сам
  # подменяет файл новой версией, как на обычных дистрибутивах.
  #
  # Свой CLI Orca регистрирует сама как ~/.local/bin/orca-ide (им пользуются
  # скиллы orca-cli/orchestration). Это скрипт, запускающий Electron из
  # распакованного AppImage с ELECTRON_RUN_AS_NODE=1 — вне FHS appimage-run,
  # поэтому Electron'овские библиотеки отдаём ему через nix-ld.
  flake.modules.nixos.orca =
    { options, pkgs, ... }:
    {
      programs.nix-ld.libraries =
        options.programs.nix-ld.libraries.default
        ++ (with pkgs; [
          alsa-lib
          at-spi2-core
          cairo
          cups
          dbus
          expat
          glib
          gtk3
          libgbm
          libx11
          libxcb
          libxcomposite
          libxdamage
          libxext
          libxfixes
          libxkbcommon
          libxrandr
          nspr
          nss
          pango
          systemd
        ]);
    };

  flake.modules.homeManager.orca =
    { pkgs, ... }:
    let
      icon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/stablyai/orca/v1.4.240/resources/build/icon.png";
        hash = "sha256-M6r7Kdr+K3vuPKcdAC8YIbvpIK5FpWQ8J/ud3tN8EuY=";
      };
      orca = pkgs.writeShellApplication {
        # Не "orca-ide": под этим именем Orca сама регистрирует CLI в ~/.local/bin,
        # и он перекрывает обёртку в PATH (запускается без FHS и падает на libglib).
        name = "orca-appimage";
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

      # `orca-ide open` иначе стартует GUI-Electron напрямую, без FHS.
      home.sessionVariables.ORCA_OPEN_COMMAND = "${orca}/bin/orca-appimage";

      # Не перехватываем markdown/csv у остальных программ, оставляем только orca://.
      xdg.desktopEntries.orca-ide = {
        name = "Orca";
        comment = "Next-gen IDE for parallel agentic development";
        exec = "${orca}/bin/orca-appimage %U";
        icon = "${icon}";
        categories = [ "Utility" ];
        mimeType = [ "x-scheme-handler/orca" ];
        settings.StartupWMClass = "orca";
      };
    };
}
