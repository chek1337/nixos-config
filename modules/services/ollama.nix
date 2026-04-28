{ ... }:
{
  flake.modules.nixos.ollama =
    { pkgs-stable, ... }:
    {
      services.ollama = {
        enable = true;
        package = pkgs-stable.ollama-cuda;
        loadModels = [ "gemma4:e2b" ];
      };
    };
}
