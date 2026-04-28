{ inputs, ... }:
{
  flake.modules.nixos.sops =
    { pkgs-stable, config, ... }:
    let
      username = config.settings.username;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      environment.systemPackages = with pkgs-stable; [ sops ];

      sops = {
        defaultSopsFile = inputs.self + "/secrets/secrets.yaml";
        validateSopsFiles = false;
        age = {
          keyFile = "/home/${username}/.config/sops/age/keys.txt";
        };
      };
    };
}
