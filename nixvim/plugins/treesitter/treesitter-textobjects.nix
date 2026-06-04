{ pkgs, ... }:
let
  selectObjs = [
    {
      i = "if";
      a = "af";
      obj = "@function";
    }
    {
      i = "ic";
      a = "ac";
      obj = "@class";
    }
    {
      i = "ia";
      a = "aa";
      obj = "@parameter";
    }
    {
      i = "iC";
      a = "aC";
      obj = "@call";
    }
    {
      i = "ib";
      a = "ab";
      obj = "@block";
    }
    {
      i = "i?";
      a = "a?";
      obj = "@conditional";
    }
    {
      i = "il";
      a = "al";
      obj = "@loop";
    }
    {
      i = "i/";
      a = "a/";
      obj = "@comment";
    }
    {
      i = "ir";
      a = "ar";
      obj = "@return";
    }
    {
      i = "i=";
      a = "a=";
      obj = "@assignment";
    }
  ];

  moveSpecs = [
    {
      key = "]f";
      fn = "goto_next_start";
      obj = "@function.outer";
    }
    {
      key = "[f";
      fn = "goto_previous_start";
      obj = "@function.outer";
    }
    {
      key = "]F";
      fn = "goto_next_end";
      obj = "@function.outer";
    }
    {
      key = "[F";
      fn = "goto_previous_end";
      obj = "@function.outer";
    }
    {
      key = "]c";
      fn = "goto_next_start";
      obj = "@class.outer";
    }
    {
      key = "[c";
      fn = "goto_previous_start";
      obj = "@class.outer";
    }
    {
      key = "]l";
      fn = "goto_next_start";
      obj = "@loop.outer";
    }
    {
      key = "[l";
      fn = "goto_previous_start";
      obj = "@loop.outer";
    }
    {
      key = "]?";
      fn = "goto_next_start";
      obj = "@conditional.outer";
    }
    {
      key = "[?";
      fn = "goto_previous_start";
      obj = "@conditional.outer";
    }
  ];

  swapSpecs = [
    {
      key = "<A-l>";
      fn = "swap_next";
      obj = "@parameter.inner";
      desc = "swap next parameter";
    }
    {
      key = "<A-h>";
      fn = "swap_previous";
      obj = "@parameter.inner";
      desc = "swap prev parameter";
    }
  ];

  renderSelect = builtins.concatStringsSep ",\n              " (
    builtins.concatMap (s: [
      ''{ key = "${s.i}", variant = "inner", obj = "${s.obj}", desc = "inner ${s.obj}" }''
      ''{ key = "${s.a}", variant = "outer", obj = "${s.obj}", desc = "outer ${s.obj}" }''
    ]) selectObjs
  );

  renderMove = builtins.concatStringsSep ",\n              " (
    map (
      m: ''{ key = "${m.key}", fn = "${m.fn}", obj = "${m.obj}", desc = "${m.key} ${m.obj}" }''
    ) moveSpecs
  );

  renderSwap = builtins.concatStringsSep ",\n              " (
    map (s: ''{ key = "${s.key}", fn = "${s.fn}", obj = "${s.obj}", desc = "${s.desc}" }'') swapSpecs
  );
in
{
  extraPlugins = [
    {
      plugin = pkgs.vimPlugins.nvim-treesitter-textobjects;
      optional = true;
    }
  ];

  plugins.lz-n.plugins = [
    {
      __unkeyed-1 = "nvim-treesitter-textobjects";
      event = "BufReadPost";
      after = # lua
        ''
          function()
            require("nvim-treesitter-textobjects.config").update({
              select = { lookahead = true },
              move   = { set_jumps = true },
            })

            local select_maps = {
              ${renderSelect}
            }
            local move_maps = {
              ${renderMove}
            }
            local swap_maps = {
              ${renderSwap}
            }

            local notified = {}
            local function have(ft)
              if ft == nil or ft == "" then return false end
              local lang = vim.treesitter.language.get_lang(ft)
              if not lang then return false end
              local ok, q = pcall(vim.treesitter.query.get, lang, "textobjects")
              if not ok then
                if not notified[lang] then
                  notified[lang] = true
                  vim.notify(
                    "Treesitter parser not installed for language: " .. lang,
                    vim.log.levels.WARN,
                    { title = "nvim-treesitter-textobjects" }
                  )
                end
                return false
              end
              return q ~= nil
            end

            local select_mode = { "o", "x" }
            local move_mode   = { "n", "x", "o" }

            local function attach(buf)
              if not vim.api.nvim_buf_is_valid(buf) then return end
              if vim.b[buf].ts_textobjects_attached then return end
              local ft = vim.bo[buf].filetype
              if not have(ft) then return end
              vim.b[buf].ts_textobjects_attached = true

              for _, m in ipairs(select_maps) do
                local query = m.obj .. "." .. m.variant
                vim.keymap.set(select_mode, m.key, function()
                  require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
                end, { buffer = buf, silent = true, desc = m.desc })
              end

              for _, m in ipairs(move_maps) do
                local key, fn, obj = m.key, m.fn, m.obj
                vim.keymap.set(move_mode, key, function()
                  if vim.wo.diff and key:find("[cC]") then
                    return vim.cmd("normal! " .. key)
                  end
                  require("nvim-treesitter-textobjects.move")[fn](obj, "textobjects")
                end, { buffer = buf, silent = true, desc = m.desc })
              end

              for _, m in ipairs(swap_maps) do
                local fn, obj = m.fn, m.obj
                vim.keymap.set("n", m.key, function()
                  require("nvim-treesitter-textobjects.swap")[fn](obj)
                end, { buffer = buf, silent = true, desc = m.desc })
              end
            end

            vim.api.nvim_create_autocmd("FileType", {
              group = vim.api.nvim_create_augroup("treesitter_textobjects_attach", { clear = true }),
              callback = function(ev) attach(ev.buf) end,
            })
            vim.tbl_map(attach, vim.api.nvim_list_bufs())
          end
        '';
    }
  ];
}
