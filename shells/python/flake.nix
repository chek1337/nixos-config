{
  description = "Python dev shell (uv-managed)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.uv
        ];

        env = {
          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
          UV_PYTHON_PREFERENCE = "managed";
        };

        shellHook = ''
          uv sync --quiet
          source .venv/bin/activate
        '';
      };
    };
}
