{ inputs, ... }:
{
  perSystem =
    { config, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      nixvimPkg = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        # Прокидываем обёрнутый standalone-yazi (packages/yazi.nix), чтобы
        # плагин qol/yazi брал именно его — с конфигом и рантайм-деками, а не
        # голый pkgs.yazi.
        extraSpecialArgs = {
          yaziPkg = config.packages.yazi;
          # В standalone-пакете нет понятия хоста/VPN, поэтому avante (ACP)
          # запускается напрямую. Реальный путь к wg-секрету для запуска через
          # vopono прокидывается в HM-сборке из nixvim.nix.
          voponoWgSecret = null;
        };
        module = {
          imports = [
            ./options.nix
            ./keymaps.nix
            ./keymaps-ru.nix
            ./spellfiles.nix
            ./plugins
          ];
          colorScheme = "nord";
        };
      };
    in
    {
      packages.nvim = nixvimPkg;
      apps.nvim = {
        type = "app";
        program = "${nixvimPkg}/bin/nvim";
      };
    };
}
