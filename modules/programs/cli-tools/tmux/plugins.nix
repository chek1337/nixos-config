{ inputs, ... }:
{
  flake.modules.homeManager.tmux-plugins =
    { pkgs, config, ... }:
    {
      programs.tmux.plugins = [
        (import ./_plugins/fingers.nix { inherit pkgs; })
        (import ./_plugins/floax.nix { inherit pkgs config inputs; })
        (import ./_plugins/catppuccin.nix { inherit pkgs config; })
        (import ./_plugins/copy-last-command.nix { inherit pkgs inputs; })
      ];
    };
}
