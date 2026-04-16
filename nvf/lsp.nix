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
    };

    languages = {
      enableTreesitter = true;
      enableFormat = true;

      nix = {
        enable = true;
        lsp.servers = [ "nixd" ];
        format.type = [ "nixfmt" ];
      };

      lua.enable = true;

      python = {
        enable = true;
        lsp.servers = [ "ty" ];
        format.type = [ "ruff" ];
      };

      clang = {
        enable = true;
        lsp.servers = [ "clangd" ];
      };

      json = {
        enable = true;
        lsp.servers = [ "vscode-json-language-server" ];
        format.type = [ "jsonfmt" ];
      };

      markdown.enable = true;
      bash.enable = true;
    };

    extraPackages = with pkgs; [
      nixd
      nixfmt
      lua-language-server
      stylua
      ruff
      basedpyright
      ty
      clang-tools
      vscode-langservers-extracted
      jsonfmt
    ];
  };
}
