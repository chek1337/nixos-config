{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.python = pkgs.mkShell {
        packages = with pkgs; [
          uv
          ruff
          pyright
        ];

        buildInputs = with pkgs; [
          zlib
          stdenv.cc.cc.lib
          openblas
        ];

        shellHook = ''
          export LD_LIBRARY_PATH="${
            pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
              pkgs.openblas
            ]
          }:$LD_LIBRARY_PATH"
        '';
      };
    };
}
