{
  flake.modules.homeManager.yazi-keybindings =
    { config, ... }:
    {
      programs.yazi.keymap.mgr.prepend_keymap = [
        {
          on = "1";
          run = "plugin relative-motions 1";
          desc = "Motion: relative 1";
        }
        {
          on = "2";
          run = "plugin relative-motions 2";
          desc = "Motion: relative 2";
        }
        {
          on = "3";
          run = "plugin relative-motions 3";
          desc = "Motion: relative 3";
        }
        {
          on = "4";
          run = "plugin relative-motions 4";
          desc = "Motion: relative 4";
        }
        {
          on = "5";
          run = "plugin relative-motions 5";
          desc = "Motion: relative 5";
        }
        {
          on = "6";
          run = "plugin relative-motions 6";
          desc = "Motion: relative 6";
        }
        {
          on = "7";
          run = "plugin relative-motions 7";
          desc = "Motion: relative 7";
        }
        {
          on = "8";
          run = "plugin relative-motions 8";
          desc = "Motion: relative 8";
        }
        {
          on = "9";
          run = "plugin relative-motions 9";
          desc = "Motion: relative 9";
        }
        {
          on = [
            "<Space>"
            "f"
            "f"
          ];
          run = "plugin television -- files";
          desc = "Find: files";
        }
        {
          on = [
            "<Space>"
            "f"
            "P"
          ];
          run = "plugin television -- files";
          desc = "Find: files (PLACEHOLDER)";
        }
        {
          on = [
            "<Space>"
            "s"
            "g"
          ];
          run = "plugin tv-grep-router";
          desc = "Search: grep text";
        }
        {
          on = [
            "<Space>"
            "s"
            "s"
          ];
          run = "plugin tv-sel";
          desc = "Search: grep in selected";
        }
        {
          on = [
            "e"
            "t"
          ];
          run = "plugin eza-preview";
          desc = "Eza-preview: toggle tree/list";
        }
        {
          on = [
            "e"
            "+"
          ];
          run = "plugin eza-preview inc-level";
          desc = "Eza-preview: tree level +";
        }
        {
          on = [
            "e"
            "-"
          ];
          run = "plugin eza-preview dec-level";
          desc = "Eza-preview: tree level -";
        }
        {
          on = [
            "e"
            "$"
          ];
          run = "plugin eza-preview toggle-follow-symlinks";
          desc = "Eza-preview: toggle follow symlinks";
        }
        {
          on = [
            "e"
            "*"
          ];
          run = "plugin eza-preview toggle-hidden";
          desc = "Eza-preview: toggle hidden";
        }
        {
          on = [
            "e"
            "g"
            "i"
          ];
          run = "plugin eza-preview toggle-git-ignore";
          desc = "Eza-preview: toggle .gitignore";
        }
        {
          on = [
            "e"
            "g"
            "s"
          ];
          run = "plugin eza-preview toggle-git-status";
          desc = "Eza-preview: toggle git status";
        }
        # I dont wanna to enter to files randomly
        # {
        #   on = "l";
        #   run = "plugin fast-enter";
        #   desc = "Enter subfolder / open file (fast-enter)";
        # }
        {
          on = "o";
          run = "open --interactive";
          desc = "Open: selected (interactive)";
        }
        {
          on = "O";
          run = "noop";
          desc = "(disabled — open interactively moved to o)";
        }
        {
          on = "r";
          run = "rename --cursor=before_ext";
          desc = "Rename: cursor before ext";
        }
        {
          on = "R";
          run = "rename --cursor=after_ext";
          desc = "Rename: cursor after ext";
        }
        {
          on = "v";
          run = "toggle";
          desc = "Select: toggle current";
        }
        {
          on = "V";
          run = "visual_mode";
          desc = "Select: visual mode";
        }
        {
          on = "d";
          run = "yank --cut";
          desc = "Cut: selected";
        }
        {
          on = "x";
          run = "remove";
          desc = "Delete: to trash";
        }
        {
          on = "X";
          run = "remove --permanently";
          desc = "Delete: permanent";
        }
        {
          on = [
            "y"
            "y"
          ];
          run = "plugin ucp copy notify";
          desc = "Yank: files (system clipboard)";
        }
        {
          on = [
            "y"
            "p"
          ];
          run = "copy path";
          desc = "Yank: full path";
        }
        {
          on = [
            "y"
            "d"
          ];
          run = "copy dirname";
          desc = "Yank: directory path";
        }
        {
          on = [
            "y"
            "n"
          ];
          run = "copy filename";
          desc = "Yank: filename";
        }
        {
          on = [
            "y"
            "N"
          ];
          run = "copy name_without_ext";
          desc = "Yank: name without ext";
        }
        {
          on = [
            "y"
            "c"
          ];
          run = "plugin copy-file-contents";
          desc = "Yank: file contents";
        }
        {
          on = "p";
          run = "plugin ucp paste notify";
          desc = "Yank: paste";
        }
        {
          on = [
            "g"
            "m"
          ];
          run = "cd /run/media/${config.settings.username}";
          desc = "Goto: mounted drives";
        }
        {
          on = [
            "g"
            "t"
          ];
          run = "cd ~/.local/share/Trash/files";
          desc = "Goto: trash";
        }
        {
          on = [
            "g"
            "D"
          ];
          run = "cd ~/Desktop";
          desc = "Goto: Desktop";
        }
        {
          on = "<C-o>";
          run = "back";
          desc = "Goto: back";
        }
        {
          on = "<C-i>";
          run = "forward";
          desc = "Goto: forward";
        }
        {
          on = "u";
          run = "plugin restore";
          desc = "Undo: last delete";
        }
        {
          on = "U";
          run = "plugin restore -- --interactive";
          desc = "Undo: interactive";
        }
        {
          on = [
            "t"
            "o"
          ];
          run = "plugin recycle-bin -- open";
          desc = "Trash: browse directory";
        }
        {
          on = [
            "t"
            "r"
          ];
          run = "plugin recycle-bin -- restore";
          desc = "Trash: restore selected";
        }
        {
          on = [
            "t"
            "X"
          ];
          run = "plugin recycle-bin -- delete";
          desc = "Trash: delete permanently";
        }
        {
          on = [
            "t"
            "e"
          ];
          run = "plugin recycle-bin -- empty";
          desc = "Trash: empty all";
        }
        {
          on = [
            "t"
            "d"
          ];
          run = "plugin recycle-bin -- emptyDays";
          desc = "Trash: empty by days";
        }
        {
          on = [
            "g"
            "M"
          ];
          run = "plugin mount";
          desc = "Mount: manager";
        }
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod: selected";
        }
        {
          on = [
            "c"
            "s"
          ];
          run = "plugin compress";
          desc = "Archive: compress";
        }
        {
          on = [
            "c"
            "x"
          ];
          run = ''shell 'ouch d -y "$@"' --block'';
          desc = "Archive: extract";
        }
        {
          on = [
            "c"
            "c"
          ];
          run = "noop";
          desc = "(disabled — copy moved to y prefix)";
        }
        {
          on = [
            "c"
            "d"
          ];
          run = "noop";
          desc = "(disabled — copy moved to y prefix)";
        }
        {
          on = [
            "c"
            "f"
          ];
          run = "noop";
          desc = "(disabled — copy moved to y prefix)";
        }
        {
          on = [
            "c"
            "n"
          ];
          run = "noop";
          desc = "(disabled — copy moved to y prefix)";
        }
        {
          on = [
            "c"
            "P"
          ];
          run = "plugin pandoc";
          desc = "Pandoc: convert document";
        }
        {
          on = [
            "c"
            "p"
          ];
          run = "plugin convert -- --extension=png";
          desc = "Convert: image to PNG";
        }
        {
          on = [
            "c"
            "j"
          ];
          run = "plugin convert -- --extension=jpg";
          desc = "Convert: image to JPG";
        }
        {
          on = [
            "c"
            "w"
          ];
          run = "plugin convert -- --extension=webp";
          desc = "Convert: image to WebP";
        }
        {
          on = [
            "m"
            "b"
          ];
          run = "plugin whoosh jump_by_fzf";
          desc = "Makrs: jump (fzf)";
        }
        {
          on = [
            "m"
            "j"
          ];
          run = "plugin whoosh jump_by_key";
          desc = "Makrs: jump (menu by key)";
        }
        {
          on = [
            "m"
            "a"
          ];
          run = "plugin whoosh save";
          desc = "Makrs: add hovered";
        }
        {
          on = [
            "m"
            "A"
          ];
          run = "plugin whoosh save_cwd";
          desc = "Makrs: add cwd";
        }
        {
          on = [
            "m"
            "t"
          ];
          run = "plugin whoosh save_temp";
          desc = "Makrs: add hovered (temp)";
        }
        {
          on = [
            "m"
            "T"
          ];
          run = "plugin whoosh save_cwd_temp";
          desc = "Makrs: add cwd (temp)";
        }
        {
          on = [
            "m"
            "d"
          ];
          run = "plugin whoosh delete_by_fzf";
          desc = "Makrs: delete (fzf)";
        }
        {
          on = [
            "m"
            "r"
          ];
          run = "plugin whoosh rename_by_fzf";
          desc = "Makrs: rename (fzf)";
        }
        {
          on = [
            "m"
            "s"
          ];
          run = "noop";
          desc = "(disabled — linemode moved to M)";
        }
        {
          on = [
            "m"
            "m"
          ];
          run = "noop";
          desc = "(disabled — linemode moved to M)";
        }
        {
          on = [
            "m"
            "p"
          ];
          run = "noop";
          desc = "(disabled — linemode moved to M)";
        }
        {
          on = [
            "m"
            "o"
          ];
          run = "noop";
          desc = "(disabled — linemode moved to M)";
        }
        {
          on = [
            "m"
            "n"
          ];
          run = "noop";
          desc = "(disabled — linemode moved to M)";
        }
        {
          on = [
            "M"
            "s"
          ];
          run = "linemode size";
          desc = "Linemode: size";
        }
        {
          on = [
            "M"
            "m"
          ];
          run = "linemode mtime";
          desc = "Linemode: mtime";
        }
        {
          on = [
            "M"
            "p"
          ];
          run = "linemode permissions";
          desc = "Linemode: permissions";
        }
        {
          on = [
            "M"
            "o"
          ];
          run = "linemode owner";
          desc = "Linemode: owner";
        }
        {
          on = [
            "M"
            "b"
          ];
          run = "linemode btime";
          desc = "Linemode: btime";
        }
        {
          on = [
            "M"
            "n"
          ];
          run = "linemode none";
          desc = "Linemode: none";
        }
        {
          on = [
            "<Space>"
            "m"
          ];
          run = "plugin toggle-pane max-preview";
          desc = "Pane: toggle max preview";
        }
        # Tabs
        {
          on = [
            "<Tab>"
            "<Tab>"
          ];
          run = "tab_create --current";
          desc = "Tab: new (cwd)";
        }
        {
          on = [
            "<Tab>"
            "x"
          ];
          run = "close";
          desc = "Tab: close";
        }
        {
          on = [
            "<Tab>"
            "]"
          ];
          run = "tab_switch 1 --relative";
          desc = "Tab: next";
        }
        {
          on = [
            "<Tab>"
            "["
          ];
          run = "tab_switch -1 --relative";
          desc = "Tab: previous";
        }
        {
          on = [
            "<Tab>"
            "f"
          ];
          run = "tab_switch 0";
          desc = "Tab: first";
        }
        {
          on = [
            "<Tab>"
            "<"
          ];
          run = "tab_swap -1";
          desc = "Tab: move left";
        }
        {
          on = [
            "<Tab>"
            ">"
          ];
          run = "tab_swap 1";
          desc = "Tab: move right";
        }
        {
          on = "K";
          run = "tab_switch 1 --relative";
          desc = "Tab: next";
        }
        {
          on = "J";
          run = "tab_switch -1 --relative";
          desc = "Tab: previous";
        }
        {
          on = "i";
          run = "spot";
          desc = "Info: spot file";
        }
      ];
    };
}
