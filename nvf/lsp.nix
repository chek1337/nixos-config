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

      nix = {
        enable = true;
        lsp.servers = [ "nixd" ];
        format.type = [ "nixfmt" ];
      };

      lua = {
        enable = true;
        lsp.lazydev.enable = true;
      };

      python = {
        enable = true;
        lsp.servers = [
          # "basedpyright"
          "ty"
        ];
        format.type = [ "ruff" ];
      };

      clang = {
        enable = true;
        cHeader = true;
        dap.enable = true;
      };

      json = {
        enable = true;
        lsp.servers = [ "vscode-json-language-server" ];
        format.type = [ "jsonfmt" ];
      };

      markdown.enable = true;
      bash.enable = true;
    };
  };
}
