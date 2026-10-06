{ config, ... }:
{
  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    caddy
  ];

  # Neovim сам не распознаёт Caddyfile: filetype остаётся пустым, и парсер
  # caddy не подключается.
  extraConfigLua = ''
    vim.filetype.add({
      filename = { Caddyfile = "caddy" },
      extension = { caddyfile = "caddy" },
    })
  '';
}
