{ ... }:
{
  vim.options.shada = "!,'100,<50,s10,h";

  vim.utility.yanky-nvim = {
    enable = true;

    setupOpts = {
      ring = {
        history_length = 100;
        storage = "shada";
        sync_with_numbered_registers = true;
        cancel_event = "update";
      };
      system_clipboard = {
        sync_with_ring = true;
      };
      highlight = {
        on_put = true;
        on_yank = true;
        timer = 250;
      };
      preserve_cursor_position.enabled = true;
    };
  };

  vim.keymaps = [
    {
      key = "p";
      mode = [
        "n"
        "x"
      ];
      action = "<Plug>(YankyPutAfter)";
      desc = "Yanky put after";
    }
    {
      key = "P";
      mode = [
        "n"
        "x"
      ];
      action = "<Plug>(YankyPutBefore)";
      desc = "Yanky put before";
    }
    {
      key = "gp";
      mode = [
        "n"
        "x"
      ];
      action = "<Plug>(YankyGPutAfter)";
      desc = "Yanky gput after";
    }
    {
      key = "gP";
      mode = [
        "n"
        "x"
      ];
      action = "<Plug>(YankyGPutBefore)";
      desc = "Yanky gput before";
    }
    {
      key = "<c-n>";
      mode = [ "n" ];
      action = "<Plug>(YankyCycleForward)";
      desc = "Yanky cycle forward";
    }
    {
      key = "<c-p>";
      mode = [ "n" ];
      action = "<Plug>(YankyCycleBackward)";
      desc = "Yanky cycle backward";
    }
    {
      key = "<leader>sy";
      mode = [ "n" ];
      lua = true;
      action = # lua
        ''
          function()
            local history = require("yanky.history")
            local entries = history.all()
            if #entries == 0 then
              vim.notify("Yank history is empty", vim.log.levels.WARN, { title = "Yanky" })
              return
            end

            local items = {}
            for i, entry in ipairs(entries) do
              local oneline = entry.regcontents:gsub("\n", " ⏎ ")
              table.insert(items, {
                idx = i,
                text = string.format("%d │ [%s] %s", i, entry.regtype, oneline),
                preview = { text = entry.regcontents, ft = "text" },
                regcontents = entry.regcontents,
                regtype = entry.regtype,
              })
            end

            require("snacks").picker.pick({
              source = "yanky",
              title = "Yank History",
              items = items,
              format = "text",
              preview = "preview",
              confirm = function(picker, item)
                picker:close()
                if not item then return end
                vim.schedule(function()
                  local reg = vim.v.register or '"'
                  vim.fn.setreg(reg, item.regcontents, item.regtype)
                  vim.cmd.normal({ args = { '"' .. reg .. "p" }, bang = true })
                end)
              end,
            })
          end
        '';
      desc = "Yank History";
    }
  ];
}
