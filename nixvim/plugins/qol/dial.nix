{ ... }:
let
  mkKey = key: mode: dir: tactic: desc: {
    __unkeyed-1 = key;
    __unkeyed-2.__raw = "function() require('dial.map').manipulate('${dir}', '${tactic}') end";
    inherit mode desc;
  };
in
{
  plugins.dial = {
    enable = true;
    lazyLoad.settings.keys = [
      (mkKey "<C-a>" "n" "increment" "normal" "Increment")
      (mkKey "<C-x>" "n" "decrement" "normal" "Decrement")
      (mkKey "g<C-a>" "n" "increment" "gnormal" "Increment (additive)")
      (mkKey "g<C-x>" "n" "decrement" "gnormal" "Decrement (additive)")
      (mkKey "<C-a>" "x" "increment" "visual" "Increment")
      (mkKey "<C-x>" "x" "decrement" "visual" "Decrement")
      (mkKey "g<C-a>" "x" "increment" "gvisual" "Increment (additive)")
      (mkKey "g<C-x>" "x" "decrement" "gvisual" "Decrement (additive)")
    ];

    # Регистрация augend-группы должна выполняться после require("dial.config"),
    # поэтому едет в luaConfig.post — он попадает в after-хук lz.n.
    luaConfig.post = # lua
      ''
        local augend = require("dial.augend")
        require("dial.config").augends:register_group({
          default = {
            augend.integer.alias.decimal,
            augend.constant.alias.bool,
            augend.constant.alias.Bool,
            augend.integer.alias.hex,
          },
        })
      '';
  };
}
