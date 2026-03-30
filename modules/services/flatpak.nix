{ inputs, ... }:
{
  flake.modules.nixos.flatpak = {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak.enable = true;
  };

  flake.modules.homeManager.flatpak = {
    imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

    services.flatpak.remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
  };
}
