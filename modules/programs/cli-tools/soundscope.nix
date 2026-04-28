{ inputs, ... }:
{
  flake.modules.homeManager.soundscope =
    { pkgs-unstable, lib, ... }:
    let
      soundscope = pkgs-unstable.rustPlatform.buildRustPackage {
        pname = "soundscope";
        version = "unstable";
        src = inputs.soundscope;
        cargoHash = "sha256-zoiRTjNBHc3/076L7JSFb1ebAOx9KgcE/PyDlIpmpZk=";

        nativeBuildInputs = [ pkgs-unstable.pkg-config ];
        buildInputs = [ pkgs-unstable.alsa-lib ];

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
