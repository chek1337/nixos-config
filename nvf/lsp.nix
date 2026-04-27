{ pkgs, ... }:
{
  vim = {
    luaConfigPost = ''
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
      })

      for _, lhs in ipairs({ "gra", "gri", "grn", "grr", "grt", "grx" }) do
        pcall(vim.keymap.del, "n", lhs)
        pcall(vim.keymap.del, "x", lhs)
      end
    '';

    lsp = {
      enable = true;
      formatOnSave = false;
      lspkind.enable = true;

      # use to many resources, so i comment it
      # servers.nixd.settings.nixd = {
      #   nixpkgs.expr = "import <nixpkgs> { }";
      #   options = {
      #     nixos.expr = ''
      #       let
      #         hostname = builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile /etc/hostname);
      #       in
      #       (builtins.getFlake "/home/chek/nixos-config").nixosConfigurations.''${hostname}.options
      #     '';
      #     home-manager.expr = ''
      #       let
      #         hostname = builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile /etc/hostname);
      #         flake = builtins.getFlake "/home/chek/nixos-config";
      #         username = flake.nixosConfigurations.''${hostname}.config.settings.username;
      #       in
      #       flake.homeConfigurations."''${username}@''${hostname}".options
      #     '';
      #   };
      # };
    };

    languages = {
      enableTreesitter = true;
      enableFormat = true;
      enableExtraDiagnostics = true;

      # Systems / compiled
      nix = {
        enable = true;
        lsp.servers = [ "nixd" ];
        format.type = [ "nixfmt" ];
      };
      clang = {
        enable = true;
        cHeader = true;
        dap.enable = true;
      };
      rust = {
        enable = true;
        dap.enable = true;
        extensions.crates-nvim.enable = true;
      };
      go.enable = true;

      # Scripting / dynamic
      lua = {
        enable = true;
        lsp.lazydev.enable = true;
      };
      python = {
        enable = true;
        lsp.servers = [
          "ty"
          "basedpyright"
        ];
        format.type = [ "ruff" ];
      };
      bash.enable = true;

      # JVM / .NET
      java.enable = true;
      csharp.enable = true;

      # Web
      typescript.enable = true;
      html.enable = true;
      css.enable = true;
      php.enable = true;

      # Data / config formats
      json = {
        enable = true;
        lsp.servers = [ "vscode-json-language-server" ];
        format.type = [ "jsonfmt" ];
      };
      yaml.enable = true;
      sql.enable = true;
      markdown.enable = true;

      # Build systems
      cmake.enable = true;
      make.enable = true;
      just.enable = true;

      # GUI
      qml.enable = true;
    };
  };
}
