{ inputs, ... }:
{
  flake.modules.homeManager.nvim =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;
        withRuby = false;
        extraPackages = with pkgs; [
          lua-language-server
          nixd
          stylua

          # Нужны для mason и LazyVim
          gcc
          unzip
          wget
          ripgrep
          fd
          luarocks
          trash-cli
        ];
      };
      programs.zsh.shellAliases = {
        v = "nvim";
      };
    };
}
