{
  flake.modules.homeManager.python-dev =
    { pkgs-stable, ... }:
    {
      home.packages = with pkgs-stable; [
        uv
        ruff
        pyright
      ];
      home.sessionPath = [ "$HOME/.local/bin" ];

      programs.zsh.shellAliases = {
        py = "uv run python";
      };
    };
}
