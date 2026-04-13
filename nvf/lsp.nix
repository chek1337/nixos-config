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
        lsp.servers = [ "basedpyright" ];
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
    ];
  };
}
