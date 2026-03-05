{
  flake.modules.homeManager.python-dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        uv
        ruff
        pyright
      ];
      home.sessionPath = [ "$HOME/.local/bin" ];
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      programs.zsh.shellAliases = {
        py = "uv run python";
      };
    };
}
