{ inputs, config, ... }:
{
  # Standalone-пакет kitty со всем моим конфигом, по образцу packages/tmux.nix
  # и nixvim/package.nix. Ставится на чужие машины (Ubuntu и т.п.) через:
  #   nix profile install github:chek1337/nixos-config#kitty
  # либо локально:  nix run .#kitty  /  nix build .#kitty
  #
  # Это per-system `packages.*`, а не дендритный HM/NixOS модуль, поэтому живёт
  # в корневом ./packages, а не среди modules/.
  #
  # Как и у tmux, HM-модуль kitty умеет только рендерить kitty.conf при
  # активации. Поэтому мы прогоняем мой modules/.../kitty.nix через минимальный
  # homeManagerConfiguration (ровно ради рендера конфига), а затем заворачиваем
  # pkgs.kitty в `kitty --config <вшитый конфиг>`. Сгенерированный конфиг
  # байт-в-байт совпадает с десктопным хостом.
  #
  # Тема stylix недоступна вне NixOS, поэтому палитра захардкожена в nord —
  # как colorScheme = "nord" у nixvim. Цвета/шрифт в kitty.conf приходят от
  # таргета stylix, поэтому stub включает stylix с nord-схемой.
  #
  # Чего НЕ хватает «голому» kitty.conf на не-NixOS машине и что мы добавляем:
  #   * рантайм-бинарники, на которые шеллится конфиг (fzf, zoxide) — на NixOS
  #     они в home.packages, тут пробрасываем их в PATH обёртки.
  # Чего пакет НЕ чинит (зависит от целевой машины, не от kitty):
  #   * kitty-scrollback.nvim: action_alias зашит на ~/.local/share/nvim/lazy/…,
  #     этот путь существует только при моём lazy.nvim. Биндинг kitty_mod+z и
  #     mouse_map просто не сработают, старт kitty при этом не ломается.
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

      # Конфиг шеллится на fzf/zoxide (hints, kitty-zoxide-sessions). На NixOS
      # они в home.packages; для портатива кладём их в PATH обёртки.
      runtimeDeps = [
        pkgs.fzf
        pkgs.zoxide
      ];

      kittyPkg = pkgs.symlinkJoin {
        name = "kitty-standalone";
        paths = [ hmConfig.config.programs.kitty.package ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/kitty \
            --add-flags "--config ${kittyConf}" \
            --prefix PATH : ${lib.makeBinPath runtimeDeps}
        '';
      };
    in
    {
      packages.kitty = kittyPkg;
      apps.kitty = {
        type = "app";
        program = "${kittyPkg}/bin/kitty";
      };
    };
}
