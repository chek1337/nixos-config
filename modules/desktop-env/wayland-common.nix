{
  flake.modules.nixos.wayland-common =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wl-clipboard
        satty
        grim
        slurp
        wayfreeze
        cliphist
      ];
    };
}
