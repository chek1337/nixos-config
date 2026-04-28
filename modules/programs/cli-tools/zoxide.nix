{
  flake.modules.homeManager.zoxide =
    { pkgs-stable, ... }:
    {
      home.packages = with pkgs-stable; [ zoxide ];

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zsh.shellAliases = {
        cd = "z";
      };
    };
}
