{ inputs, config, ... }:
{
  # Standalone-пакет zsh со всем моим конфигом, по образцу packages/tmux.nix,
  # packages/yazi.nix и packages/nvim.nix. Ставится на чужие машины (Ubuntu
  # и т.п.) через:
  #   nix profile install github:chek1337/nixos-config#zsh
  # либо локально:  nix run .#zsh  /  nix build .#zsh
  #
  # Это per-system `packages.*`, а не дендритный HM/NixOS модуль, поэтому живёт
  # в корневом ./packages, а не среди modules/.
  #
  # Как и у tmux/yazi, HM-модуль zsh умеет только рендерить дотфайлы при
  # активации (.zshrc / .zshenv c вшитыми store-путями плагинов: oh-my-zsh,
  # autosuggestions, syntax-highlighting, а также eval-строками fzf/zoxide/
  # starship/direnv). Поэтому мы прогоняем мои shells/zsh + интеграционные
  # модули (zoxide/eza/direnv) через минимальный homeManagerConfiguration
  # (ровно ради рендера дотфайлов), собираем их в один каталог и заворачиваем
  # pkgs.zsh так, чтобы он читал его через ZDOTDIR. Сгенерированный конфиг
  # байт-в-байт совпадает с десктопным хостом.
  #
  # Тема stylix вне NixOS недоступна, но zsh-модуль её и не использует —
  # цвета в терминал приносят starship/syntax-highlighting сами. stylix в stub
  # включён лишь чтобы eza/zoxide/direnv корректно вычислились (общий контракт
  # с остальными standalone-пакетами).
  #
  # Чего НЕ хватает «голым» дотфайлам zsh на не-NixOS машине и что мы добавляем:
  #   * рантайм-бинарники, на которые eval-строки .zshrc шеллятся в рантайме:
  #     fzf (его key-bindings.zsh вызывает сам бинарь fzf), zoxide, starship,
  #     direnv, git (плагин git у oh-my-zsh), eza (мои алиасы l/ls/tree).
  #     На NixOS они в home.packages — тут пробрасываем их в PATH обёртки.
  #   * STARSHIP_CONFIG → вшитый starship.toml (truncation_length = 0 и т.д.),
  #     иначе на чужой машине starship возьмёт дефолты вместо моих настроек.
  #   * HISTFILE: HM хардкодит его в homeDirectory eval'а (/home/zsh/...), что
  #     на целевой машине не существует. Переопределяем history.path на $HOME,
  #     чтобы история писалась в реальный домашний каталог пользователя.
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

      # Идентичность + захардкоженный nord stylix для standalone HM-eval'а
      # (нужен eza/zoxide/direnv по общему контракту с tmux/yazi).
      stub = {
        home.username = "zsh";
        home.homeDirectory = "/home/zsh";
        home.stateVersion = "25.11";
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
          hmMods.zsh
          hmMods.zoxide
          hmMods.eza
          hmMods.direnv
          stub
          # HISTFILE → реальный $HOME целевой машины, а не /home/zsh из stub.
          { programs.zsh.history.path = "$HOME/.zsh_history"; }
        ];
      };

      # Собираем дотфайлы zsh (.zshrc/.zshenv/.zprofile/.zlogin/.zlogout) из
      # home.file в один каталог и указываем на него через ZDOTDIR. Так обёртка
      # самодостаточна и не зависит от того, какие именно файлы отрендерил HM.
      # Ключи home.file у zsh-модуля выглядят как "./.zshrc", поэтому фильтруем
      # по .target (= ".zshrc"), а не по имени атрибута.
      allFiles = lib.attrValues hmConfig.config.home.file;
      isZshDotfile =
        f:
        lib.elem (baseNameOf f.target) [
          ".zshrc"
          ".zshenv"
          ".zprofile"
          ".zlogin"
          ".zlogout"
        ];
      zshDotfiles = lib.filter isZshDotfile allFiles;
      zshConfigDir = pkgs.runCommand "zsh-standalone-config" { } (
        ''
          mkdir -p "$out"
        ''
        + lib.concatStringsSep "\n" (
          map (f: ''install -Dm644 ${f.source} "$out/${baseNameOf f.target}"'') zshDotfiles
        )
        # HM хардкодит stub-домашний каталог /home/zsh в некоторых местах (напр.
        # ZSH_CACHE_DIR=/home/zsh/.cache/oh-my-zsh в .zshenv) — на чужой машине его
        # нет и oh-my-zsh не может писать кэш. Заменяем на литеральный $HOME, чтобы
        # пути резолвились в рантайме. Store-пути /home/zsh не содержат, безопасно.
        + ''

          chmod -R u+w "$out"
          for f in "$out"/.*; do
            [ -f "$f" ] && substituteInPlace "$f" --replace-quiet "/home/zsh" "\$HOME"
          done
        ''
        # ZDOTDIR указывает на этот неизменяемый store-каталог, поэтому реальный
        # ~/.zshrc целевой машины zsh НЕ читает. Чтобы конфиг можно было
        # дополнять локально (PATH, алиасы, секреты конкретной машины), в самый
        # конец вшитого .zshrc — уже после oh-my-zsh/zoxide — дописываем загрузку
        # пользовательского ~/.zshrc.local, если он есть. $out read-only, поэтому
        # снимаем флаг записи временно через chmod.
        + ''

          chmod u+w "$out/.zshrc"
          cat >> "$out/.zshrc" <<'EOF'

          # --- standalone-пакет: локальные дополнения пользователя ---
          # ZDOTDIR указывает на store, реальный ~/.zshrc не читается. Свои
          # машинно-зависимые правки клади в ~/.zshrc.local — он подхватится тут.
          if [[ -f "$HOME/.zshrc.local" ]]; then
            source "$HOME/.zshrc.local"
          fi
          EOF
          chmod u-w "$out/.zshrc"
        ''
      );

      # starship.toml в этом eval'е оседает не в xdg.configFile, а в home.file
      # (xdg.enable выключен), поэтому ищем запись по суффиксу target, не по ключу.
      starshipConf =
        (lib.findFirst (
          f: lib.hasSuffix "starship.toml" f.target
        ) (throw "starship.toml not rendered by HM eval") allFiles).source;

      # На NixOS бинарники интеграций лежат в home.packages. Берём их, но
      # выкидываем десктопный хлам, который stylix тащит в профиль (шрифты,
      # gtk/kde-темы, mime, man-db, ...) — для портативного zsh он не нужен и
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
        pkgs.fzf
        pkgs.zoxide
        pkgs.eza
        pkgs.starship
        pkgs.direnv
        pkgs.git
      ];

      zshPkg = pkgs.symlinkJoin {
        name = "zsh-standalone";
        paths = [ pkgs.zsh ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zsh \
            --set ZDOTDIR ${zshConfigDir} \
            --set STARSHIP_CONFIG ${starshipConf} \
            --prefix PATH : ${lib.makeBinPath runtimeDeps}
        '';
      };
    in
    {
      packages.zsh = zshPkg;
      apps.zsh = {
        type = "app";
        program = "${zshPkg}/bin/zsh";
      };
    };
}
