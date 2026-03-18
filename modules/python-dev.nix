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

      programs.zsh.shellAliases = {
        py = "uv run python";
      };
    };
}
