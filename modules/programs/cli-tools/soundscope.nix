{ inputs, ... }:
{
  flake.modules.homeManager.soundscope =
    { pkgs, lib, ... }:
    let
      soundscope = pkgs.rustPlatform.buildRustPackage {
        pname = "soundscope";
        version = "unstable";
        src = inputs.soundscope;

        cargoHash = "sha256-Z/6mi7rWXxF4V5E2TyIWPXp3blRq9BQ5IrvsZPvnRWo=";

        meta = {
          description = "CLI audio file analyzer";
          homepage = "https://github.com/bananaofhappiness/soundscope";
          license = lib.licenses.mit;
          mainProgram = "soundscope";
        };
      };
    in
    {
      home.packages = [ soundscope ];
    };
}
