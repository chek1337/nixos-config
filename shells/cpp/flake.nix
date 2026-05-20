{
  description = "C/C++ dev shell (clang toolchain)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default =
        (pkgs.mkShell.override { stdenv = pkgs.clangStdenv; }) {
          # Local dev/debug build: drop hardening so Debug is clean -O0.
          hardeningDisable = [ "all" ];

          packages = with pkgs; [
            cmake
            ninja
            clang-tools # clangd
            lldb # lldb-dap
            lld
            pkg-config
          ];

          env = {
            CC = "clang";
            CXX = "clang++";
          };
        };
    };
}
