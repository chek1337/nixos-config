{ pkgs, config, ... }:
{
  plugins.lsp.servers.clangd = {
    enable = true;
    settings.InlayHints = {
      Enabled = true;
      DeducedTypes = true;
      ParameterNames = true;
      Designators = true;
    };
  };

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    c
    cpp
    cuda
  ];

  globals.c_syntax_for_h = 1;

  plugins.dap.adapters.executables.lldb = {
    command = "${pkgs.lldb}/bin/lldb-dap";
  };

  plugins.dap.configurations.c = [
    {
      name = "Launch (lldb-dap)";
      type = "lldb";
      request = "launch";
      program.__raw = ''
        function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end
      '';
      cwd = "\${workspaceFolder}";
      stopOnEntry = false;
    }
  ];

  plugins.dap.configurations.cpp = [
    {
      name = "Launch (lldb-dap)";
      type = "lldb";
      request = "launch";
      program.__raw = ''
        function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end
      '';
      cwd = "\${workspaceFolder}";
      stopOnEntry = false;
    }
  ];

  extraPackages = with pkgs; [
    clang-tools
    lldb
  ];
}
