{ pkgs, ... }:
{
  # async.nvim — рантайм-зависимость refactoring.nvim, нужна на rtp заранее.
  # refactoring.nvim уходит в pack/opt/ и подгружается lz-n по первому биндингу.
  extraPlugins = [
    pkgs.vimPlugins.async-nvim
    {
      plugin = pkgs.vimPlugins.refactoring-nvim;
      optional = true;
    }
  ];

  plugins.lz-n.plugins = [
    {
      __unkeyed-1 = "refactoring.nvim";
      after = # lua
        ''
          function()
            -- Доопределяем code_generation, которого нет в upstream для cpp:
            --  * inline_var.group_expression.cpp     — копия c-версии
            --  * inline_func.assignment.cpp          — через `auto x = y;`
            -- Без этого <leader>ri / <leader>rI на C++ падают
            -- ("There's no `group_expression`/`assignment` code generation ...").
            require("refactoring").setup({
              refactor = {
                inline_var = {
                  code_generation = {
                    group_expression = {
                      cpp = function(opts)
                        return ("(%s)"):format(opts.expression)
                      end,
                    },
                  },
                },
                inline_func = {
                  code_generation = {
                    assignment = {
                      cpp = function(opts)
                        if #opts.left == 0 then return "" end
                        -- Lua-версия балансирует длины nil-ами;
                        -- в C++ для незаполненных правых частей кладём `{}`
                        -- (default-init: 0 для арифметики, пустой объект и т.п.).
                        if #opts.left < #opts.right then
                          for _ = #opts.left + 1, #opts.right do
                            table.remove(opts.right)
                          end
                        elseif #opts.right < #opts.left then
                          for _ = #opts.right + 1, #opts.left do
                            table.insert(opts.right, "{}")
                          end
                        end
                        -- В C++ нет parallel-присваивания, разворачиваем
                        -- в построчные `auto name = expr;` — `auto` дешевле,
                        local lines = {}
                        for i, l in ipairs(opts.left) do
                          table.insert(lines,
                            ("auto %s = %s;"):format(l, opts.right[i]))
                        end
                        return table.concat(lines, "\n")
                      end,
                    },
                  },
                },
              },
            })
          end
        '';
    }
  ];

  plugins.lz-n.keymaps = [
    {
      plugin = "refactoring.nvim";
      key = "<leader>re";
      mode = [
        "n"
        "x"
      ];
      action.__raw = ''function() return require("refactoring").extract_func() end'';
      options = {
        desc = "Refactor: Extract Function";
        expr = true;
      };
    }
    {
      plugin = "refactoring.nvim";
      key = "<leader>ree";
      mode = "n";
      action.__raw = ''function() return require("refactoring").extract_func() .. "_" end'';
      options = {
        desc = "Refactor: Extract Function (line)";
        expr = true;
      };
    }
    {
      plugin = "refactoring.nvim";
      key = "<leader>rE";
      mode = [
        "n"
        "x"
      ];
      action.__raw = ''function() return require("refactoring").extract_func_to_file() end'';
      options = {
        desc = "Refactor: Extract Function To File";
        expr = true;
      };
    }
    {
      plugin = "refactoring.nvim";
      key = "<leader>rv";
      mode = [
        "n"
        "x"
      ];
      action.__raw = ''function() return require("refactoring").extract_var() end'';
      options = {
        desc = "Refactor: Extract Variable";
        expr = true;
      };
    }
    {
      plugin = "refactoring.nvim";
      key = "<leader>rvv";
      mode = "n";
      action.__raw = ''function() return require("refactoring").extract_var() .. "_" end'';
      options = {
        desc = "Refactor: Extract Variable (line)";
        expr = true;
      };
    }
    {
      plugin = "refactoring.nvim";
      key = "<leader>ri";
      mode = [
        "n"
        "x"
      ];
      action.__raw = ''function() return require("refactoring").inline_var() end'';
      options = {
        desc = "Refactor: Inline Variable";
        expr = true;
      };
    }
    {
      plugin = "refactoring.nvim";
      key = "<leader>rI";
      mode = [
        "n"
        "x"
      ];
      action.__raw = ''function() return require("refactoring").inline_func() end'';
      options = {
        desc = "Refactor: Inline Function";
        expr = true;
      };
    }
    {
      plugin = "refactoring.nvim";
      key = "<leader>rs";
      mode = [
        "n"
        "x"
      ];
      action.__raw = ''function() require("refactoring").select_refactor() end'';
      options.desc = "Refactor: Select…";
    }
  ];
}
