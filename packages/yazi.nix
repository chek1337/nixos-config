{ inputs, config, ... }:
{
  # Standalone-пакет yazi со всем моим конфигом, по образцу packages/tmux.nix,
  # packages/kitty.nix и packages/nvim.nix. Ставится на чужие машины (Ubuntu
  # и т.п.) через:
  #   nix profile install github:chek1337/nixos-config#yazi
  # либо локально:  nix run .#yazi  /  nix build .#yazi
  #
  # Это per-system `packages.*`, а не дендритный HM/NixOS модуль, поэтому живёт
  # в корневом ./packages, а не среди modules/.
  #
  # Как и у tmux/kitty, HM-модуль yazi умеет только рендерить конфиг при
  # активации (yazi.toml / keymap.toml / theme.toml / init.lua / plugins/*).
  # Поэтому мы прогоняем мои modules/.../yazi/* через минимальный
  # homeManagerConfiguration (ровно ради рендера конфига), собираем всё
  # поддерево `yazi/` из xdg.configFile в один каталог и заворачиваем
  # pkgs.yazi так, чтобы он читал его через YAZI_CONFIG_HOME. Сгенерированный
  # конфиг байт-в-байт совпадает с десктопным хостом.
  #
  # Тема stylix недоступна вне NixOS, поэтому палитра захардкожена в nord —
  # как colorScheme = "nord" у nixvim. theme.toml у yazi приходит от таргета
  # stylix, поэтому stub включает stylix с nord-схемой.
  #
  # Чего НЕ хватает «голому» конфигу yazi на не-NixOS машине и что мы добавляем:
  #   * рантайм-бинарники, на которые шеллятся конфиг и плагины — на NixOS они
  #     в home.packages, тут пробрасываем их в PATH обёртки. Базовые превью-деки
  #     (file, ffmpeg, 7z, jq, resvg, poppler, ...) уже зашиты в апстрим-обёртку
  #     pkgs.yazi; мы добавляем то, что тянет именно мой конфиг: glow, hexyl,
  #     sqlite, duckdb, ouch, mediainfo, pandoc, transmission, imagemagick,
  #     trash-cli, udisks2, p7zip, zip, wl-clipboard/xclip (ucp), плюс
  #     bat/eza/ripgrep/fd/fzf/zoxide и television (каналы files/text для
  #     <Space>ff и поиска).
  # Чего пакет НЕ чинит (зависит от целевой машины, не от yazi):
  #   * tv-sel / tv-grep открывают найденное в `nvim` (путь захардкожен в Lua).
  #     Если на хосте нет nvim — эти биндинги не сработают, сам yazi стартует.
  #   * NVIM_CWD-ветки роутеров рассчитаны на запуск yazi внутри моего nixvim;
  #     в standalone они просто не активируются.
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = pkgs.lib;
      hmLib = inputs.home-manager.lib;
      hmMods = config.flake.modules.homeManager;

      # Идентичность + захардкоженный nord stylix для standalone HM-eval'а.
      stub = {
        home.username = "yazi";
        home.homeDirectory = "/home/yazi";
        home.stateVersion = "25.11";
        # yazi-keybindings шеллится на settings.username (g m → /run/media/<user>),
        # этой опции нет в голом HM, объявляем заглушку.
        settings.username = "yazi";
        stylix = {
          enable = true;
          polarity = "dark";
          base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
        };
      };

      hmConfig = hmLib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.stylix.homeModules.default
          hmMods.yazi
          # settings.username не объявлена в голом HM — добавляем опцию, чтобы
          # модуль yazi-keybindings мог её прочитать.
          (
            { lib, ... }:
            {
              options.settings.username = lib.mkOption {
                type = lib.types.str;
                default = "yazi";
              };
            }
          )
          stub
        ];
      };

      yazi = hmConfig.config.programs.yazi.package;

      # Собираем всё поддерево `yazi/` из xdg.configFile в один каталог и
      # указываем на него через YAZI_CONFIG_HOME. Так обёртка самодостаточна и
      # не зависит от того, какие именно файлы отрендерил HM-модуль.
      yaziConfigDir = pkgs.runCommand "yazi-standalone-config" { } (
        ''
          mkdir -p "$out"
        ''
        + lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: file:
            let
              dst = ''"$out/${lib.removePrefix "yazi/" name}"'';
            in
            # configFile-записи бывают и файлами (yazi.toml, init.lua), и
            # каталогами (плагины *.yazi). cp -r покрывает оба случая.
            ''mkdir -p "$(dirname ${dst})" && cp -r ${file.source} ${dst}''
          ) (lib.filterAttrs (n: _: lib.hasPrefix "yazi/" n) hmConfig.config.xdg.configFile)
        )
      );

      # На NixOS превью/плагины тянут бинарники из home.packages. Берём их, но
      # выкидываем десктопный хлам, который stylix тащит в профиль (шрифты,
      # gtk/kde-темы, mime, man-db, ...) — для портативного yazi он не нужен и
      # только раздувает closure.
      desktopJunk = [
        "font"
        "dejavu"
        "noto"
        "adwaita"
        "adw-gtk"
        "kde-theme"
        "kde-config"
        "gnome-shell"
        "icon-theme"
        "cursor"
        "man-db"
        "mime"
        "xdg"
        "session-vars"
        "configuration-reference"
        "stylix"
      ];
      isCliTool = p: !(lib.any (s: lib.hasInfix s (p.pname or p.name or "")) desktopJunk);
      runtimeDeps = (lib.filter isCliTool hmConfig.config.home.packages) ++ [
        pkgs.bat
        pkgs.eza
        pkgs.ripgrep
        pkgs.fd
        pkgs.fzf
        pkgs.zoxide
        pkgs.television
        pkgs.glow
      ];

      yaziPkg = pkgs.symlinkJoin {
        name = "yazi-standalone";
        paths = [ yazi ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          for b in yazi ya; do
            wrapProgram "$out/bin/$b" \
              --set YAZI_CONFIG_HOME ${yaziConfigDir} \
              --prefix PATH : ${lib.makeBinPath runtimeDeps}
          done
        '';
      };
    in
    {
      packages.yazi = yaziPkg;
      apps.yazi = {
        type = "app";
        program = "${yaziPkg}/bin/yazi";
      };
    };
}
