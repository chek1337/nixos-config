{ inputs, ... }:
{
  flake.modules.homeManager.tmux-plugins =
    { pkgs-unstable, config, ... }:
    {
      programs.tmux.plugins = [
        (import ./_plugins/fingers.nix { inherit pkgs-unstable; })
        (import ./_plugins/floax.nix { inherit pkgs-unstable config inputs; })
        (import ./_plugins/catppuccin.nix { inherit pkgs-unstable config; })
      ];
    };
}
