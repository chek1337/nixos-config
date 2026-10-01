{ pkgs, config, ... }:
{
  plugins.lsp.servers.yamlls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    yaml
    gotmpl
    helm
  ];

  # YAML с шаблонами Go (traefik dynamic, helm): строки вида `{{- if ... }}`
  # ломают грамматику yaml, и подсветка пропадает целиком. Такие файлы
  # открываем как helm: это gotmpl, у которого текст между действиями
  # подсвечивается как yaml. Ansible пишет `{{ }}` в кавычках, его не трогаем.
  extraConfigLua = ''
    local function yaml_or_gotmpl(_, buf)
      if not buf then
        return "yaml"
      end
      for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 200, false)) do
        if line:match("^%s*{{") then
          return "helm"
        end
      end
      return "yaml"
    end

    vim.filetype.add({
      extension = {
        yml = yaml_or_gotmpl,
        yaml = yaml_or_gotmpl,
      },
    })
  '';

  extraPackages = with pkgs; [
    yaml-language-server
  ];
}
