{ inputs, ... }:
{
  flake.modules.nixos.nixos =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
      boot = {
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts;
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };
    };
}
