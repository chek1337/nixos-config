{
  description = "CUDA dev shell (nvcc 12.6 + uv + torch/triton)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
      cudaPkgs = pkgs.cudaPackages_12_6;
    in
    {
      devShells.${system}.default = (pkgs.mkShell.override { stdenv = pkgs.gcc13Stdenv; }) {
        # Local dev/debug build: drop hardening so Debug is clean -O0.
        hardeningDisable = [ "all" ];

        packages = with pkgs; [
          # CUDA toolchain (nvcc, cuBLAS, cuRAND, cuFFT, cuSPARSE, cuSOLVER, NVTX, CUPTI)
          cudaPkgs.cudatoolkit
          cudaPkgs.cudnn

          # Profilers
          cudaPkgs.nsight_compute
          cudaPkgs.nsight_systems

          # Build chain — nvcc only supports gcc, not clang
          gcc13
          cmake
          ninja
          gnumake
          pkg-config

          # Python tooling
          uv
        ];

        env = {
          CUDA_HOME = "${cudaPkgs.cudatoolkit}";
          CUDA_PATH = "${cudaPkgs.cudatoolkit}";
          CUDAToolkit_ROOT = "${cudaPkgs.cudatoolkit}";

          # RTX 4050 (Ada Lovelace) = sm_89
          CUDAARCHS = "89";
          TORCH_CUDA_ARCH_LIST = "8.9";

          # Pin nvcc's host compiler so it doesn't pick a wrong gcc off PATH
          NVCC_PREPEND_FLAGS = "-ccbin ${pkgs.gcc13}/bin/gcc";

          # pre-built torch/triton wheels need libstdc++ and the NixOS NVIDIA
          # userspace driver libs (libcuda.so, libnvidia-ml.so) from /run/opengl-driver/lib.
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [
            cudaPkgs.cudatoolkit
            cudaPkgs.cudnn
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
            pkgs.libGL
            pkgs.glib
          ]}:/run/opengl-driver/lib";

          UV_PYTHON_PREFERENCE = "managed";
        };

        shellHook = ''
          if [ -f pyproject.toml ]; then
            uv sync --quiet
            source .venv/bin/activate
          fi
        '';
      };
    };
}
