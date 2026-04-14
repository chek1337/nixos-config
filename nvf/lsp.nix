{ pkgs, ... }:
{
  vim = {
    lsp = {
      enable = true;
      formatOnSave = false;
      trouble.enable = true;
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
        lsp.servers = [ "jsonls" ];
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
