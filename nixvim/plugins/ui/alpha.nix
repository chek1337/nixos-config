{ ... }:
let
  lua = code: { __raw = code; };
  keymap = key: command: [
    "n"
    "${key}"
    "<cmd>${command}<cr>"
    {
      noremap = true;
      silent = true;
      nowait = true;
    }
  ];
in
{
  plugins.web-devicons.enable = true;

  plugins.alpha = {
    enable = true;
    theme = null;
    settings.layout = [
      {
        type = "padding";
        val = 15;
      }

      {
        type = "text";
        val = [
          "      ████ ██████           █████      ██                     "
          "     ███████████             █████                             "
          "     █████████ ███████████████████ ███   ███████████    "
          "    █████████  ███    █████████████ █████ ██████████████    "
          "   █████████ ██████████ █████████ █████ █████ ████ █████    "
          " ███████████ ███    ███ █████████ █████ █████ ████ █████  "
          "██████  █████████████████████ ████ █████ █████ ████ ██████ "
        ];
        opts = {
          position = "center";
          hl = "Type";
        };
      }

      {
        type = "padding";
        val = 2;
      }

      {
        type = "group";
        val = [
          {
            type = "button";
            val = "  New File";
            on_press = ":ene | startinsert";
            opts = {
              position = "center";
              shortcut = "n";
              keymap = keymap "n" "ene | startinsert";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "  Find File";
            on_press = lua ''function() require("snacks").picker.files() end'';
            opts = {
              position = "center";
              shortcut = "f";
              keymap = keymap "f" "lua require('snacks').picker.files()";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "  Find Text";
            on_press = lua ''function() require("snacks").picker.grep() end'';
            opts = {
              position = "center";
              shortcut = "g";
              keymap = keymap "g" "lua require('snacks').picker.grep()";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "  Recent Files";
            on_press = lua ''function() require("snacks").picker.recent() end'';
            opts = {
              position = "center";
              shortcut = "r";
              keymap = keymap "r" "lua require('snacks').picker.recent()";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "  Restore Session";
            on_press = lua ''function() require("persistence").load() end'';
            opts = {
              position = "center";
              shortcut = "s";
              keymap = keymap "s" "lua require('persistence').load()";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "  Quit";
            on_press = ":qa";
            opts = {
              position = "center";
              shortcut = "q";
              keymap = keymap "q" "qa";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
        ];
        opts = {
          spacing = 1;
          position = "center";
          hl = "Function";
        };
      }
    ];
  };
}
