{ ... }:
{
  flake.modules.nixos.ollama =
    { pkgs, ... }:
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
        loadModels = [ "gemma4:e2b" ];
      };
    };
}
