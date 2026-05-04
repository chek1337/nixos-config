{
  flake.modules.homeManager.python-dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        uv
        ruff
        pyright
        (python3.withPackages (
          ps: with ps; [
            pip
            python-docx
          ]
        ))
      ];
      home.sessionPath = [ "$HOME/.local/bin" ];

      programs.zsh.shellAliases = {
        py = "uv run python";
      };
    };
}
