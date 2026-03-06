{ inputs, ... }:
{
  flake.modules.nixos.sops =
    { ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = inputs.self + "/secrets/secrets.yaml";
        validateSopsFiles = false;
        age = {
          # TODO fix chek
          keyFile = "/home/chek/.config/sops/age/keys.txt";
        };
      };
    };
}
