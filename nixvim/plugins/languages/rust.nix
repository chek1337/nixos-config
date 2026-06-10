{ pkgs, config, ... }:
{
  # plugins.rustaceanvim = {
  #   enable = true;
  #   lazyLoad.settings.ft = "rust";
  #   settings = {
  #     server.default_settings."rust-analyzer".cargo.allFeatures = true;
  #     dap.adapter.__raw = ''
  #       {
  #         type = "server",
  #         host = "127.0.0.1",
  #         port = "$${port}",
  #         executable = {
  #           command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter}/bin/codelldb",
  #           args = { "--port", "$${port}" },
  #         },
  #       }
  #     '';
  #   };
  # };
  #
  # plugins.crates = {
  #   enable = true;
  #   lazyLoad.settings.ft = "toml";
  # };
  #
  # plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
  #   rust
  # ];
  #
  # extraPackages = with pkgs; [
  #   rust-analyzer
  #   vscode-extensions.vadimcn.vscode-lldb.adapter
  # ];
}
