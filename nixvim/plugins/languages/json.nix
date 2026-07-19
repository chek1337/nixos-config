{ pkgs, config, ... }:
{
  # jsonls обслуживает как чистый JSON, так и JSON-с-комментариями и json5.
  plugins.lsp.servers.jsonls = {
    enable = true;
    filetypes = [
      "json"
      "jsonc"
      "json5"
    ];
  };

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    json
    json5
  ];

  plugins.conform-nvim.settings.formatters_by_ft = {
    json = [ "jsonfmt" ];
    jsonc = [ "jsonfmt" ];
    json5 = [ "jsonfmt" ];
  };

  extraConfigLua = ''
    -- jsonc/json5 не имеют отдельных treesitter-грамматик — используем json/json5.
    vim.treesitter.language.register("json", "jsonc")

    -- Файлы «JSON по своей сути», которые по имени/расширению не детектятся
    -- как json. Форматы с комментариями/trailing-запятыми маппим на jsonc,
    -- строгие потоковые/схемные — на json.
    vim.filetype.add({
      extension = {
        jsonl = "json",
        ndjson = "json",
        geojson = "json",
        topojson = "json",
        har = "json",
        avsc = "json",
        arb = "json",
        jsonld = "json",
        jsonc = "jsonc",
      },
      filename = {
        [".babelrc"] = "jsonc",
        [".jscsrc"] = "jsonc",
        [".jshintrc"] = "jsonc",
        [".swcrc"] = "jsonc",
        [".hintrc"] = "jsonc",
        [".prettierrc"] = "jsonc",
        [".stylelintrc"] = "jsonc",
        [".eslintrc"] = "jsonc",
        ["jsconfig.json"] = "jsonc",
        ["tsconfig.json"] = "jsonc",
        ["devcontainer.json"] = "jsonc",
        [".babelrc.json"] = "jsonc",
      },
      pattern = {
        [".*/%.vscode/.*%.json"] = "jsonc",
        ["tsconfig%..*%.json"] = "jsonc",
        [".*%.code%-workspace"] = "jsonc",
      },
    })
  '';

  extraPackages = with pkgs; [
    vscode-langservers-extracted
    jsonfmt
  ];
}
