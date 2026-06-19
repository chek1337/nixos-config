{ inputs, ... }:
{
  flake.modules.homeManager.nixvim =
    { pkgs, config, ... }:
    {
      stylix.targets.neovim.enable = false;

      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;
        nixpkgs.pkgs = pkgs;
        imports = [
          # Прокидываем обёрнутый standalone-yazi (packages/yazi.nix) как module
          # arg, чтобы плагин qol/yazi брал его и в HM-сборке, а не только в
          # standalone-пакете (nixvim/package.nix, где он идёт через
          # extraSpecialArgs).
          { _module.args.yaziPkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.yazi; }
          # Путь к sops-секрету WireGuard для запуска avante/ACP через vopono
          # (см. plugins/ai/avante.nix). Host-specific, поэтому прокидываем
          # отсюда; в standalone-пакете .#nvim его нет → агент идёт напрямую.
          { _module.args.voponoWgSecret = "/run/secrets/${config.settings.wireguardConfigName}"; }
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
