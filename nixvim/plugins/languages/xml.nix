{ config, ... }:
{
  plugins.lsp.servers.lemminx.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    xml
  ];

  # friendly-snippets не содержит xml.json (только html.json), поэтому
  # переиспользуем HTML-сниппеты в xml-файлах: blink-источник `snippets`
  # подтянет html.json для filetype `xml`. Триггеры вроде `div`, `a:link`
  # станут доступны в .xml.
  plugins.blink-cmp.settings.sources.providers.snippets.opts.extended_filetypes.xml = [
    "html"
  ];
}
