{ config, ... }:
{
  flake.modules.homeManager.cli-tools = {
    imports = with config.flake.modules.homeManager; [
      eza
      yazi
      git
      tmux
      zellij
      nvim
      zoxide
      trash-cli
      btop
      bat
      pay-respects
    ];
  };
}
