{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    iron-nvim = {
      package = iron-nvim;
      after = [ "venv-selector-nvim" ];
      setup = ''
        local iron = require("iron.core")
        local view = require("iron.view")

        local screen_h = vim.opt.lines:get()

        iron.setup({
          config = {
            scratch_repl = true,
            repl_definition = {
              sh = {
                command = { "zsh" },
              },
              python = {
                command = function()
                  local venv_path = require("venv-selector").venv()
                  local venv_name = ""

                  if venv_path and venv_path ~= "" then
                    venv_name = vim.fn.fnamemodify(venv_path, ":t")
                  else
                    venv_name = "Global Python"
                  end

                  return {
                    "ipython",
                    "--no-autoindent",
                    "-c",
                    "import sys; print('========================= iron.nvim REPL =========================='); print('Venv:', '"
                      .. venv_name
                      .. "'); print('Python:', sys.version.split()[0]); print('===================================================================')",
                    "-i",
                  }
                end,
                format = function(lines, extras)
                  result = require("iron.fts.common").bracketed_paste_python(lines, extras)
                  filtered = vim.tbl_filter(function(line)
                    return not string.match(line, "^%s*#")
                  end, result)
                  return filtered
                end,
                block_dividers = { "# %%", "#%%" },
                env = { PYTHON_BASIC_REPL = "1" },
              },
            },
            repl_filetype = function(bufnr, ft)
              return ft
            end,
            dap_integration = true,
            repl_open_cmd = {
              view.offset({
                width = "40%",
                height = screen_h - 2,
                w_offset = view.helpers.flip(0),
                h_offset = view.helpers.flip(1),
              }),
            },
          },
          keymaps = {
            toggle_repl_with_cmd_1 = "<localleader>\\",
            restart_repl = "<C-\\>",
            send_motion = "<Nop>",
            visual_send = "<localleader>ss",
            send_file = "<localleader>sf",
            send_line = "<localleader>sl",
            send_paragraph = "<localleader>sp",
            send_until_cursor = "<localleader>su",
            send_mark = "<Nop>",
            send_code_block = "<localleader>ss",
            send_code_block_and_move = "<M-\\>",
            mark_motion = "<Nop>",
            mark_visual = "<Nop>",
            remove_mark = "<Nop>",
            cr = "<localleader>s<cr>",
            interrupt = "<localleader>si",
            exit = "<Nop>",
            clear = "<localleader>sc",
          },
          highlight = {
            italic = true,
          },
          ignore_blank_lines = true,
        })
      '';
    };
  };
}
