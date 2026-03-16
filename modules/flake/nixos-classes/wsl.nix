{ inputs, ... }:
{
  flake.modules.nixos.wsl =
    { username, ... }:
    {
      imports = [ inputs.nixos-wsl.nixosModules.default ];
      wsl.enable = true;
      wsl.defaultUser = username;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      programs.nix-ld.enable = true;
    };
}
