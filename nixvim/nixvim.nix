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
          ./options.nix
          ./keymaps.nix
          ./keymaps-ru.nix
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
