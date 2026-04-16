{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    nvim-treesitter-textobjects = {
      package = nvim-treesitter-textobjects;
      after = [ "nvim-treesitter" ];
      setup = ''
        require("nvim-treesitter-textobjects.config").update({
          select = { lookahead = true },
          move   = { set_jumps = true },
        })

        local sel  = require("nvim-treesitter-textobjects.select")
        local mov  = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")

        local ox  = { "o", "x" }
        local nxo = { "n", "x", "o" }

        -- ── Select ──────────────────────────────────────────────────────────
        -- if/af  function      ic/ac  class        ia/aa  argument/parameter
        -- iC/aC  call          ib/ab  block        i?/a?  conditional
        -- il/al  loop          i//a/  comment      ir/ar  return
        -- i=/a=  assignment
        local select_maps = {
          { "if", "af", "@function"   },
          { "ic", "ac", "@class"      },
          { "ia", "aa", "@parameter"  },
          { "iC", "aC", "@call"       },
          { "ib", "ab", "@block"      },
          { "i?", "a?", "@conditional"},
          { "il", "al", "@loop"       },
          { "i/", "a/", "@comment"    },
          { "ir", "ar", "@return"     },
          { "i=", "a=", "@assignment" },
        }
        for _, m in ipairs(select_maps) do
          local inner, outer, obj = m[1], m[2], m[3]
          vim.keymap.set(ox, inner, function()
            sel.select_textobject(obj .. ".inner", "textobjects")
          end, { desc = "inner " .. obj })
          vim.keymap.set(ox, outer, function()
            sel.select_textobject(obj .. ".outer", "textobjects")
          end, { desc = "outer " .. obj })
        end

        -- ── Move ────────────────────────────────────────────────────────────
        -- ]f/[f  next/prev function start   ]F/[F  next/prev function end
        -- ]c/[c  next/prev class            ]l/[l  next/prev loop
        -- ]?/[?  next/prev conditional
        local function mk_move(key, fn, obj)
          vim.keymap.set(nxo, key, function()
            fn(obj, "textobjects")
          end, { desc = key .. " " .. obj })
        end

        mk_move("]f",  mov.goto_next_start,    "@function.outer")
        mk_move("[f",  mov.goto_previous_start, "@function.outer")
        mk_move("]F",  mov.goto_next_end,       "@function.outer")
        mk_move("[F",  mov.goto_previous_end,   "@function.outer")
        mk_move("]c",  mov.goto_next_start,    "@class.outer")
        mk_move("[c",  mov.goto_previous_start, "@class.outer")
        mk_move("]l",  mov.goto_next_start,    "@loop.outer")
        mk_move("[l",  mov.goto_previous_start, "@loop.outer")
        mk_move("]?",  mov.goto_next_start,    "@conditional.outer")
        mk_move("[?",  mov.goto_previous_start, "@conditional.outer")

        -- ── Swap ────────────────────────────────────────────────────────────
        -- <A-l>  swap next parameter    <A-h>  swap prev parameter
        vim.keymap.set("n", "<A-l>", function()
          swap.swap_next("@parameter.inner")
        end, { desc = "swap next parameter" })
        vim.keymap.set("n", "<A-h>", function()
          swap.swap_previous("@parameter.inner")
        end, { desc = "swap prev parameter" })
      '';
    };
  };
}
