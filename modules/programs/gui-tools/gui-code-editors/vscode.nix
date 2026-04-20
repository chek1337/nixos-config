{
  flake.modules.homeManager.vscode =
    { pkgs, ... }:
    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode;
        profiles.default.extensions =
          with pkgs.vscode-extensions;
          [
            llvm-vs-code-extensions.vscode-clangd
            ms-vscode.cmake-tools
            ms-vscode-remote.remote-containers
            ms-azuretools.vscode-docker
            twxs.cmake
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
