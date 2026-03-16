# Shell option: zsh
# Select in hosts/*/default.nix via: shell = "zsh"
{
  flake.modules.nixos.zsh =
    { pkgs, username, ... }:
    {
      programs.zsh.enable = true;
      users.users.${username}.shell = pkgs.zsh;
    };

  flake.modules.homeManager.zsh =
    { pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" ];
        };
        initContent = ''
                WORDCHARS='*?_[]~=&;!#$%^(){}'
                bindkey " " magic-space
          bindkey '^H' backward-kill-word
          bindkey '\e[127;5~' backward-kill-word
          bindkey '\e[127;5u' backward-kill-word
          source ${pkgs.fzf}/share/fzf/key-bindings.zsh
          source ${pkgs.fzf}/share/fzf/completion.zsh
        '';
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          directory = {
            truncation_length = 0;
            truncate_to_repo = false;
          };
        };
      };
    };
}
