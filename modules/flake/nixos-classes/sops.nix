{ inputs, pkgs, ... }:
{
  flake.modules.nixos.sops =
    { pkgs, username, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      environment.systemPackages = with pkgs; [ sops ];

      sops = {
        defaultSopsFile = inputs.self + "/secrets/secrets.yaml";
        validateSopsFiles = false;
        age = {
          keyFile = "/home/${username}/.config/sops/age/keys.txt";
        };
      };
    };
}
