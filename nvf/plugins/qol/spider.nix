{ pkgs, ... }:
{
  vim = {
    luaPackages = [ "luautf8" ];

    extraPlugins = with pkgs.vimPlugins; {
      nvim-spider = {
        package = nvim-spider;
        setup = # lua
          ''
            require("spider").setup({
              skipInsignificantPunctuation = true,
              subwordMovement = true,
              consistentOperatorPending = false,
            })

            local spider_toggle = Snacks.toggle({
              name = "Spider motions",
              get = function()
                return vim.g.spider_mode == true
              end,
              set = function(state)
                vim.g.spider_mode = state
                if state then
                  vim.keymap.set({ "n", "o", "x" }, "w", function() require("spider").motion("w") end, { silent = true })
                  vim.keymap.set({ "n", "o", "x" }, "e", function() require("spider").motion("e") end, { silent = true })
                  vim.keymap.set({ "n", "o", "x" }, "b", function() require("spider").motion("b") end, { silent = true })
                  vim.keymap.set({ "n", "o", "x" }, "ge", function() require("spider").motion("ge") end, { silent = true })
                else
                  vim.keymap.del({ "n", "o", "x" }, "w")
                  vim.keymap.del({ "n", "o", "x" }, "e")
                  vim.keymap.del({ "n", "o", "x" }, "b")
                  vim.keymap.del({ "n", "o", "x" }, "ge")
                end
              end,
            })

            spider_toggle:map("<leader>u*")
            spider_toggle:set(true)
          '';
      };
    };
  };
}
