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
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      hmConfig = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.stylix.homeModules.default
          config.flake.modules.homeManager.tmux
          {
            home.username = "tmux";
            home.homeDirectory = "/home/tmux";
            home.stateVersion = "25.11";

            # Минимальный stylix только ради config.lib.stylix.colors,
            # которые читает modules/.../tmux/theme.nix.
            stylix = {
              enable = true;
              polarity = "dark";
              base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
            };
          }
        ];
      };

      tmuxConf = hmConfig.config.xdg.configFile."tmux/tmux.conf".source;

      tmuxPkg = pkgs.symlinkJoin {
        name = "tmux-standalone";
        paths = [ hmConfig.config.programs.tmux.package ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tmux \
            --add-flags "-f ${tmuxConf}"
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
