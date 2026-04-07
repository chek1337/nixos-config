{
  flake.modules.homeManager.wallpaper-colorizer =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        (rustPlatform.buildRustPackage {
          pname = "dipc";
          version = "1.2.0";

          src = fetchFromGitHub {
            owner = "doprz";
            repo = "dipc";
            rev = "v1.2.0";
            hash = "sha256-sK4wyrEr1RCdug6uDjFQvMlZzrhPAcXi6yTiiWiPQcc=";
          };

          cargoHash = "sha256-BCJXROjsaztzv6HWi1+i2GYCoeEgdXbYrEjpEdUvGFg=";
        })
        gowall
      ];
    };
}
