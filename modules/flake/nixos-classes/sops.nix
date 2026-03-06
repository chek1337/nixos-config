{ inputs, pkgs, ... }:
{
  flake.modules.nixos.sops =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      environment.systemPackages = with pkgs; [ sops ];

      sops = {
        defaultSopsFile = inputs.self + "/secrets/secrets.yaml";
        validateSopsFiles = false;
        age = {
          keyFile = "/home/chek/.config/sops/age/keys.txt";
        };
      };
    };
}
