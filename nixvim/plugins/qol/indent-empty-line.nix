{ ... }:
{
  # Авто-отступ при входе в insert на ПУСТОЙ строке.
  #
  # Новую строку через o/O/Enter внутри блока уже корректно отбивает treesitter
  # (indent.enable = true) через indentexpr. Не покрыт один кейс: курсор встал на
  # уже существующую пустую строку — Neovim ставит в колонку 0 и отступ не
  # угадывается. Здесь i/a/A/I на пустой строке подменяются на `cc`, который
  # переотбивает строку через indentexpr и заходит в insert на нужном уровне
  # ("_ — чтобы не затирать неименованный регистр пустотой).
  keymaps =
    let
      smartInsert = key: ''
        function()
          if vim.api.nvim_get_current_line():match("^%s*$") then
            return [["_cc]]
          end
          return "${key}"
        end
      '';
    in
    map
      (key: {
        inherit key;
        mode = "n";
        action.__raw = smartInsert key;
        options = {
          expr = true;
          silent = true;
          desc = "Insert (${key}) with auto-indent on empty line";
        };
      })
      [
        "i"
        "I"
        "a"
        "A"
      ];
}
