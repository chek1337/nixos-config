{
  flake.modules.homeManager.vscode =
    { pkgs-stable, ... }:
    {
      programs.vscode = {
        enable = true;
        package = pkgs-stable.vscode;
        profiles.default.extensions =
          with pkgs-stable.vscode-extensions;
          [
            llvm-vs-code-extensions.vscode-clangd
            ms-vscode.cmake-tools
            ms-vscode-remote.remote-containers
            ms-azuretools.vscode-docker
            twxs.cmake
          ]
          ++ pkgs-stable.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "yocto-bitbake";
              publisher = "yocto-project";
              version = "2.1.0";
              sha256 = "sha256-X7igyJb5NSZbxxOMQS+bd052tXU7pUfCc2CRGRHusBQ=";
            }
          ];
      };
    };
}
