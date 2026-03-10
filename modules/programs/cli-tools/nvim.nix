{ inputs, ... }:
{
  flake.modules.homeManager.nvim =
    { pkgs, ... }:
    {
      imports = [ inputs.lazyvim-nix.homeManagerModules.default ];

      programs.lazyvim = {
        enable = true;
        installCoreDependencies = true;

        extraPackages = with pkgs; [
          nixd
          stylua
        ];

        configFiles = ./nvim-config;
      };

      programs.zsh.shellAliases = {
        v = "nvim";
      };
    };
}
