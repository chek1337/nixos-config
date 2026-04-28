{ inputs, ... }:
{
  flake.modules.nixos.installer =
    { pkgs-stable, ... }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
      ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs-stable; [
        git
        vim
        parted
        gptfdisk
        dosfstools
      ];
    };
}
