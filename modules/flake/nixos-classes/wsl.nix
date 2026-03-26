{ inputs, ... }:
{
  flake.modules.nixos.wsl =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      imports = [ inputs.nixos-wsl.nixosModules.default ];
      wsl.enable = true;
      wsl.defaultUser = username;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nixpkgs.config.allowUnfree = true;
      programs.nix-ld.enable = true;
    };
}
