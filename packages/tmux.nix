{ inputs, config, ... }:
{
  # Standalone-пакет tmux со всем моим конфигом, по образцу nixvim/package.nix.
  # Ставится на чужие машины (Ubuntu и т.п.) через:
  #   nix profile install github:chek1337/nixos-config#tmux
  # либо локально:  nix run .#tmux  /  nix build .#tmux
  #
  # Это per-system `packages.*`, а не дендритный HM/NixOS модуль, поэтому живёт
  # в корневом ./packages, а не среди modules/.
  #
  # В отличие от nvim здесь нет фабрики makeTmuxWithModule: HM-модуль tmux умеет
  # только рендерить tmux.conf при активации. Поэтому мы прогоняем мои tmux-*
  # модули через минимальный homeManagerConfiguration (ровно ради рендера
  # конфига), а затем заворачиваем pkgs.tmux в `tmux -f <вшитый конфиг>`.
  #
  # Тема stylix недоступна вне NixOS, поэтому палитра захардкожена в nord —
  # как colorScheme = "nord" у nixvim. Плагины в сгенерированном tmux.conf
  # подключаются через `run-shell <store-path>`, так что обёртка самодостаточна.
  #
  # Чего НЕ хватает «голому» tmux.conf на не-NixOS машине и что мы добавляем:
  #   * рантайм-бинарники (sesh, tmuxinator, tmux-last, fzf, zoxide, eza, ...) —
  #     на NixOS они в home.packages, тут пробрасываем их в PATH обёртки;
  #   * канал television `sesh` — живёт в отдельном модуле television, его tv
  #     ищет в XDG. Чтобы не трогать XDG_CONFIG_HOME (иначе шеллы в панелях
  #     потеряют свой конфиг), оборачиваем сам бинарь tv флагом --cable-dir.
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

      # Идентичность + захардкоженный nord stylix для standalone HM-eval'ов.
      stub = {
        home.username = "tmux";
        home.homeDirectory = "/home/tmux";
        home.stateVersion = "25.11";
        stylix = {
          enable = true;
          polarity = "dark";
          base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
        };
      };

      # --- television: вшиваем канал sesh, чтобы `tv sesh` работал вне NixOS ---
      # Рендерим конфиг television, складываем его в каталог и оборачиваем tv так,
      # чтобы он читал каналы через --cable-dir. XDG_CONFIG_HOME не трогаем — иначе
      # его унаследуют шеллы внутри панелей и потеряют свой конфиг.
      tvEval = hmLib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.stylix.homeModules.default
          hmMods.television
          stub
        ];
      };
      tvConfigDir = pkgs.runCommand "tmux-tv-config" { } (
        ''
          mkdir -p "$out"
        ''
        + lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: file: ''install -Dm644 ${file.source} "$out/${lib.removePrefix "television/" name}"''
          ) (lib.filterAttrs (n: _: lib.hasPrefix "television/" n) tvEval.config.xdg.configFile)
        )
      );
      television = pkgs.symlinkJoin {
        name = "television-tmux";
        paths = [ pkgs.television ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tv --add-flags "--cable-dir ${tvConfigDir}/cable"
        '';
      };

      # --- основной eval tmux ---
      # Подменяем pkgs.television на обёрнутый, чтобы скрипт sesh-tv (он зашит на
      # ${pkgs.television}/bin/tv) находил канал sesh. Заодно тянем модуль
      # television ради его рантайм-зависимостей (fd/bat/jq) в home.packages.
      hmConfig = hmLib.homeManagerConfiguration {
        pkgs = pkgs.extend (_: _: { inherit television; });
        modules = [
          inputs.stylix.homeModules.default
          hmMods.tmux
          hmMods.television
          stub
        ];
      };

      tmuxConf = hmConfig.config.xdg.configFile."tmux/tmux.conf".source;

      # Всё, на что конфиг шеллится: sesh, tmuxinator, tmux-last и popup-скрипты,
      # обёрнутый television, fd/bat/jq, плюс zoxide/fzf/eza для источника и
      # превью канала sesh. Берём из home.packages, но выкидываем десктопный хлам,
      # который stylix тащит в профиль (шрифты, gtk/kde-темы, mime, man-db, ...) —
      # для портативного tmux он не нужен и только раздувает closure.
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
        "desktop" # sesh.desktop GUI-лаунчер тянет kitty — для портатива не нужен
        "session-vars"
        "configuration-reference"
        "stylix"
      ];
      isCliTool = p: !(lib.any (s: lib.hasInfix s (p.pname or p.name or "")) desktopJunk);
      runtimeDeps = (lib.filter isCliTool hmConfig.config.home.packages) ++ [
        pkgs.zoxide
        pkgs.fzf
        pkgs.eza
      ];

      tmuxPkg = pkgs.symlinkJoin {
        name = "tmux-standalone";
        paths = [ hmConfig.config.programs.tmux.package ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tmux \
            --add-flags "-f ${tmuxConf}" \
            --prefix PATH : ${lib.makeBinPath runtimeDeps}
        '';
      };
    in
    {
      packages.tmux = tmuxPkg;
      apps.tmux = {
        type = "app";
        program = "${tmuxPkg}/bin/tmux";
      };
    };
}
