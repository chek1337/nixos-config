{ inputs, ... }:
{
  flake.modules.homeManager.nixvim =
    { pkgs, config, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;
        nixpkgs.pkgs = pkgs;
        imports = [
          ./options.nix
          ./plugins
        ];
      };

      # Сосуществование с nvf (он держит `nvim` на hiPrio): nixvim
      # доступен под отдельным именем `nxvim` через wrapper-скрипт.
      home.packages = [
        (pkgs.writeShellScriptBin "nxvim" ''
          exec ${config.programs.nixvim.build.package}/bin/nvim "$@"
        '')
      ];

      programs.zsh.shellAliases.nx = "nxvim";
    };
}
