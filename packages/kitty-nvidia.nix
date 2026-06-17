{ inputs, config, ... }:
{
  # NVIDIA-вариант standalone-пакета kitty. Всё как в packages/kitty.nix
  # (рендер моего конфига + захардкоженный nord, обёртка bin/kitty), но GPU-враппер
  # здесь — nixGLNvidia вместо nixGLIntel. Ставится на чужие машины с NVIDIA:
  #   nix profile install github:chek1337/nixos-config#kitty-nvidia
  #   nix run .#kitty-nvidia  /  nix build .#kitty-nvidia
  #
  # ВАЖНО про воспроизводимость: userspace-библиотека nixGL обязана совпасть с
  # версией ядерного модуля NVIDIA на хосте, иначе GL не стартует. Поэтому версия
  # драйвера ЗАПИНЕНА здесь (nvidiaVersion) — это плата за «чистый» пакет без
  # --impure. Когда хост обновит драйвер NVIDIA, бампни nvidiaVersion (и при
  # необходимости nvidiaHash). Узнать версию на хосте:
  #   nvidia-smi --query-gpu=driver_version --format=csv,noheader
  #
  # Mesa-вариант (#kitty) к версии драйвера не привязан — см. packages/kitty.nix,
  # там же подробные комментарии про рендер конфига и nord.
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

      # Версия драйвера NVIDIA на целевом хосте (Ubuntu 22.04, RTX 4060).
      # Должна совпадать с `nvidia-smi` на машине, где запускается kitty.
      nvidiaVersion = "580.159.03";
      # SRI-хеш .run-инсталлятора этой версии. В pure-eval flake fetchurl без хеша
      # не работает; заодно делает сборку воспроизводимой. При смене nvidiaVersion
      # пересчитать:
      #   nix-prefetch-url "https://download.nvidia.com/XFree86/Linux-x86_64/<ver>/NVIDIA-Linux-x86_64-<ver>.run"
      nvidiaHash = "sha256-MshdmbD2QMlQH2GzndrSCP0CiNAVxPvF/QQ1wHeD+nc=";

      # Идентичность + захардкоженный nord stylix для standalone HM-eval'а.
      stub = {
        home.username = "kitty";
        home.homeDirectory = "/home/kitty";
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
          hmMods.kitty
          stub
        ];
      };

      kittyConf = hmConfig.config.xdg.configFile."kitty/kitty.conf".source;
      kitty = hmConfig.config.programs.kitty.package;

      # nixGLNvidia, собранный под конкретную версию драйвера (см. выше). Импортим
      # nixGL напрямую через default.nix, чтобы передать nvidiaVersion — у flake-
      # выхода nixGLNvidia версия определяется только импурно (--impure).
      #
      # Собираем на nixpkgs самого nixGL (follows -> nixpkgs-stable, см. flake.nix),
      # а не на моём unstable: nixGL строит nvidia-либы через
      # nvidia_x11.override { kernel = null; }, а в свежем nixpkgs этот аргумент
      # убран → eval-ошибка. Обёртка лишь экспортит env и exec'ает kitty, так что
      # версия mesa/glvnd из stable-nixpkgs тут безвредна.
      nixglPkgs = import inputs.nixGL.inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      nixGL =
        (import "${inputs.nixGL}" {
          pkgs = nixglPkgs;
          inherit nvidiaVersion nvidiaHash;
        }).nixGLNvidia;

      runtimeDeps = [
        pkgs.fzf
        pkgs.zoxide
      ];

      kittyPkg = pkgs.symlinkJoin {
        name = "kitty-nvidia-standalone";
        paths = [ kitty ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm "$out/bin/kitty"
          makeWrapper ${nixGL}/bin/nixGLNvidia-${nvidiaVersion} "$out/bin/kitty" \
            --add-flags "${kitty}/bin/kitty" \
            --add-flags "--config ${kittyConf}" \
            --prefix PATH : ${lib.makeBinPath runtimeDeps}
        '';
      };
    in
    {
      packages.kitty-nvidia = kittyPkg;
      apps.kitty-nvidia = {
        type = "app";
        program = "${kittyPkg}/bin/kitty";
      };
    };
}
