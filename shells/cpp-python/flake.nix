{
  description = "C++/Python dev shell (clang + uv + pybind11)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
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
            # C++ build chain
            cmake
            ninja
            clang-tools # clangd
            lldb # lldb-dap + lldb-server
            lld
            pkg-config
            eigen
            nlohmann_json
            python3Packages.pybind11

            # task runner + Python tooling
            just
            uv
            python3Packages.debugpy
          ];

          env = {
            # pre-built manylinux wheels (numpy/scipy/matplotlib) need libstdc++;
            # PySide6 bundled-Qt needs the system X11/Wayland/xcb stack on NixOS.
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
              pkgs.libGL
              pkgs.glib
              pkgs.fontconfig.lib
              pkgs.freetype
              pkgs.dbus.lib
              pkgs.libxkbcommon
              pkgs.wayland
              pkgs.zlib
              pkgs.zstd
              pkgs.xorg.libX11
              pkgs.xorg.libxcb
              pkgs.xorg.libXext
              pkgs.xorg.libXrender
              pkgs.xorg.libXi
              pkgs.xorg.libXrandr
              pkgs.xorg.libXcursor
              pkgs.xorg.libXfixes
              pkgs.xorg.libXdamage
              pkgs.xorg.libXcomposite
              pkgs.xorg.libXtst
              pkgs.xorg.libSM
              pkgs.xorg.libICE
              pkgs.xorg.xcbutil
              pkgs.xorg.xcbutilwm
              pkgs.xorg.xcbutilimage
              pkgs.xorg.xcbutilkeysyms
              pkgs.xorg.xcbutilrenderutil
              pkgs.xorg.xcbutilcursor
            ];
            UV_PYTHON_PREFERENCE = "managed";
            CC = "clang";
            CXX = "clang++";
          };

          shellHook = ''
            uv sync --quiet
            source .venv/bin/activate
          '';
        };
    };
}
