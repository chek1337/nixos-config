{ inputs, ... }:
{
  flake.modules.homeManager.nixvim =
    {
      pkgs,
      pkgs-stable,
      config,
      ...
    }:
    {
      stylix.targets.neovim.enable = false;

      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;
        nixpkgs.pkgs = pkgs;
        imports = [
          # Прокидываем обёрнутый standalone-yazi (packages/yazi.nix) как module
          # arg, чтобы плагин qol/yazi брал его и в HM-сборке, а не только в
          # standalone-пакете (packages/nvim.nix, где он идёт через
          # extraSpecialArgs).
          { _module.args.yaziPkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.yazi; }
          # Тот же pkgs-stable, что и у остальных HM-модулей: отдельные плагины
          # пинят на stable пакеты, которых нет в кэше unstable
          # (см. plugins/languages/sql.nix). NB: при добавлении нового
          # module arg его нужно прокинуть и в packages/nvim.nix — standalone-
          # сборка nvim импортирует те же ./plugins.
          { _module.args.pkgs-stable = pkgs-stable; }
          ./options.nix
          ./keymaps.nix
          ./keymaps-ru.nix
          ./spellfiles.nix
          ./plugins
        ];
        colorScheme = config.settings.colorScheme;
      };
      programs.zsh.shellAliases = {
        v = "nvim";
        ngit = "nvim +Neogit";
      };
    };
}
