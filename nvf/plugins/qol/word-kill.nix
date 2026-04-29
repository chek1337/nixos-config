{ ... }:
{
  vim = {
    luaConfigRC.zsh-style-word-kill = # lua
      ''
        local M = {}

        -- Класс символа: 's' = whitespace, 'w' = alnum (без _), 'p' = special.
        -- Совпадает с z4h: zsh [[:alnum:]] не включает '_'.
        local function classify(ch)
          if ch:match('%s') then return 's' end
          if ch:match('%w') then return 'w' end
          return 'p'
        end

        -- Возвращает (new_text, new_left_count) после "z4h-backward-kill-word".
        -- left = число байт слева от курсора в исходном тексте.
        local function compute_back(text, left)
          if left == 0 then return text, left end
          local pos = left
          while pos > 0 and text:sub(pos, pos):match('%s') do
            pos = pos - 1
          end
          if pos > 0 then
            local cls = classify(text:sub(pos, pos))
            while pos > 0 and classify(text:sub(pos, pos)) == cls do
              pos = pos - 1
            end
          end
          return text:sub(1, pos) .. text:sub(left + 1), pos
        end

        -- z4h-kill-word (вперёд). Курсор не двигается.
        local function compute_forward(text, left)
          local len = #text
          if left >= len then return text, left end
          local pos = left + 1
          while pos <= len and text:sub(pos, pos):match('%s') do
            pos = pos + 1
          end
          if pos <= len then
            local cls = classify(text:sub(pos, pos))
            while pos <= len and classify(text:sub(pos, pos)) == cls do
              pos = pos + 1
            end
          end
          return text:sub(1, left) .. text:sub(pos), left
        end

        -- z4h-backward-kill-zword: до ближайшего пробела (целый аргумент).
        local function compute_back_zword(text, left)
          if left == 0 then return text, left end
          local pos = left
          while pos > 0 and text:sub(pos, pos):match('%s') do
            pos = pos - 1
          end
          while pos > 0 and not text:sub(pos, pos):match('%s') do
            pos = pos - 1
          end
          return text:sub(1, pos) .. text:sub(left + 1), pos
        end

        -- Insert-mode обёртки (текст текущей строки буфера)
        local function buf_apply(fn)
          local r, c = unpack(vim.api.nvim_win_get_cursor(0))
          local line = vim.api.nvim_get_current_line()
          local new_line, new_c = fn(line, c)
          if new_line ~= line then
            vim.api.nvim_set_current_line(new_line)
            vim.api.nvim_win_set_cursor(0, { r, new_c })
          end
        end

        function M.backward_kill_word() buf_apply(compute_back) end
        function M.kill_word() buf_apply(compute_forward) end
        function M.backward_kill_zword() buf_apply(compute_back_zword) end

        -- Cmdline-mode обёртки.
        --
        -- setcmdline() из lua-callback'а не пробрасывает свежий
        -- `cmdline_show` UI-event, пока коллбэк не отработает, поэтому
        -- ext_cmdline UI вроде noice показывает изменения только после
        -- следующей клавиши. Вместо setcmdline считаем, сколько символов
        -- удалить, и шлём ровно столько нативных <BS>/<Del> через
        -- feedkeys — они идут штатным cmdline-путём и UI обновляется
        -- сразу.
        local BS = vim.api.nvim_replace_termcodes('<BS>', true, false, true)
        local DEL = vim.api.nvim_replace_termcodes('<Del>', true, false, true)

        local function cmd_kill_back(fn)
          local line = vim.fn.getcmdline()
          local left = vim.fn.getcmdpos() - 1
          local _, new_left = fn(line, left)
          if new_left >= left then return end
          local nchars = vim.fn.strchars(line:sub(new_left + 1, left))
          vim.api.nvim_feedkeys(string.rep(BS, nchars), 'n', false)
        end

        local function cmd_kill_forward(fn)
          local line = vim.fn.getcmdline()
          local left = vim.fn.getcmdpos() - 1
          local new_line, _ = fn(line, left)
          if #new_line >= #line then return end
          local nchars = vim.fn.strchars(line:sub(left + 1, left + (#line - #new_line)))
          vim.api.nvim_feedkeys(string.rep(DEL, nchars), 'n', false)
        end

        function M.cmd_backward_kill_word() cmd_kill_back(compute_back) end
        function M.cmd_kill_word() cmd_kill_forward(compute_forward) end
        function M.cmd_backward_kill_zword() cmd_kill_back(compute_back_zword) end

        _G.zsh_word_kill = M
      '';

    keymaps = [
      {
        key = "<C-W>";
        mode = "i";
        lua = true;
        action = "function() _G.zsh_word_kill.backward_kill_word() end";
        desc = "z4h backward-kill-word";
      }
      {
        key = "<C-Del>";
        mode = "i";
        lua = true;
        action = "function() _G.zsh_word_kill.kill_word() end";
        desc = "z4h kill-word forward";
      }
      {
        key = "<M-BS>";
        mode = "i";
        lua = true;
        action = "function() _G.zsh_word_kill.backward_kill_zword() end";
        desc = "z4h backward-kill-zword (whole arg)";
      }

      {
        key = "<C-W>";
        mode = "c";
        lua = true;
        action = "function() _G.zsh_word_kill.cmd_backward_kill_word() end";
        desc = "z4h backward-kill-word (cmdline)";
      }
      {
        key = "<C-Del>";
        mode = "c";
        lua = true;
        action = "function() _G.zsh_word_kill.cmd_kill_word() end";
        desc = "z4h kill-word forward (cmdline)";
      }
      {
        key = "<M-BS>";
        mode = "c";
        lua = true;
        action = "function() _G.zsh_word_kill.cmd_backward_kill_zword() end";
        desc = "z4h backward-kill-zword (cmdline)";
      }
    ];
  };
}
