{
  flake.modules.homeManager.yazi-keybindings =
    { config, ... }:
    {
      programs.yazi.keymap.mgr.prepend_keymap = [
        {
          on = "1";
          run = "plugin relative-motions 1";
          desc = "Relative motion 1";
        }
        {
          on = "2";
          run = "plugin relative-motions 2";
          desc = "Relative motion 2";
        }
        {
          on = "3";
          run = "plugin relative-motions 3";
          desc = "Relative motion 3";
        }
        {
          on = "4";
          run = "plugin relative-motions 4";
          desc = "Relative motion 4";
        }
        {
          on = "5";
          run = "plugin relative-motions 5";
          desc = "Relative motion 5";
        }
        {
          on = "6";
          run = "plugin relative-motions 6";
          desc = "Relative motion 6";
        }
        {
          on = "7";
          run = "plugin relative-motions 7";
          desc = "Relative motion 7";
        }
        {
          on = "8";
          run = "plugin relative-motions 8";
          desc = "Relative motion 8";
        }
        {
          on = "9";
          run = "plugin relative-motions 9";
          desc = "Relative motion 9";
        }
        {
          on = [
            "<Space>"
            "f"
            "f"
          ];
          run = "plugin television -- files";
          desc = "Find files (television)";
        }
        {
          on = [
            "<Space>"
            "f"
            "P"
          ];
          run = "plugin television -- files";
          desc = "Find files (television) - PLACEHOLDER";
        }
        {
          on = [
            "<Space>"
            "s"
            "g"
          ];
          run = "plugin tv-grep-router";
          desc = "Grep text (tv standalone / snacks.picker in nvim)";
        }
        {
          on = [
            "<Space>"
            "s"
            "s"
          ];
          run = "plugin tv-sel";
          desc = "Grep in selected files (television)";
        }
        {
          on = [
            "e"
            "t"
          ];
          run = "plugin eza-preview";
          desc = "Toggle tree/list dir preview";
        }
        {
          on = [
            "e"
            "+"
          ];
          run = "plugin eza-preview inc-level";
          desc = "Increment tree level";
        }
        {
          on = [
            "e"
            "-"
          ];
          run = "plugin eza-preview dec-level";
          desc = "Decrement tree level";
        }
        {
          on = [
            "e"
            "$"
          ];
          run = "plugin eza-preview toggle-follow-symlinks";
          desc = "Toggle tree follow symlinks";
        }
        {
          on = [
            "e"
            "*"
          ];
          run = "plugin eza-preview toggle-hidden";
          desc = "Toggle hidden files";
        }
        {
          on = [
            "e"
            "g"
            "i"
          ];
          run = "plugin eza-preview toggle-git-ignore";
          desc = "Toggle .gitignore files";
        }
        {
          on = [
            "e"
            "g"
            "s"
          ];
          run = "plugin eza-preview toggle-git-status";
          desc = "Toggle showing git status";
        }
        # I dont wanna to enter to files randomly
        # {
        #   on = "l";
        #   run = "plugin fast-enter";
        #   desc = "Enter subfolder / open file (fast-enter)";
        # }
        {
          on = "r";
          run = "rename --cursor=before_ext";
          desc = "Rename (cursor before ext)";
        }
        {
          on = "R";
          run = "rename --cursor=after_ext";
          desc = "Rename (cursor after ext)";
        }
        {
          on = "v";
          run = "toggle";
          desc = "Toggle selection of current file";
        }
        {
          on = "V";
          run = "visual_mode";
          desc = "Start visual selection (group)";
        }
        {
          on = "d";
          run = "yank --cut";
          desc = "Cut selected files";
        }
        {
          on = "x";
          run = "remove";
          desc = "Move selected files to trash";
        }
        {
          on = "X";
          run = "remove --permanently";
          desc = "Permanently delete selected files";
        }
        {
          on = [
            "y"
            "y"
          ];
          run = "plugin ucp copy notify";
          desc = "Copy files to system clipboard (ucp)";
        }
        {
          on = [
            "y"
            "p"
          ];
          run = "copy path";
          desc = "Copy: full path";
        }
        {
          on = [
            "y"
            "d"
          ];
          run = "copy dirname";
          desc = "Copy: directory path";
        }
        {
          on = [
            "y"
            "n"
          ];
          run = "copy filename";
          desc = "Copy: filename (with ext)";
        }
        {
          on = [
            "y"
            "N"
          ];
          run = "copy name_without_ext";
          desc = "Copy: name (without ext)";
        }
        {
          on = [
            "y"
            "c"
          ];
          run = "plugin copy-file-contents";
          desc = "Copy: file contents";
        }
        {
          on = "p";
          run = "plugin ucp paste notify";
          desc = "Paste from system clipboard (ucp)";
        }
        {
          on = [
            "g"
            "m"
          ];
          run = "cd /run/media/${config.settings.username}";
          desc = "Go to mounted drives";
        }
        {
          on = "<C-o>";
          run = "back";
          desc = "Back to previous directory";
        }
        {
          on = "<C-i>";
          run = "forward";
          desc = "Forward to next directory";
        }
        {
          on = "u";
          run = "plugin restore";
          desc = "Restore last deleted (restore)";
        }
        {
          on = [
            "<Space>"
            "r"
            "b"
          ];
          run = "plugin recycle-bin";
          desc = "Open recycle bin";
        }
        {
          on = [
            "g"
            "M"
          ];
          run = "plugin mount";
          desc = "Mount manager";
        }
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod selected files";
        }
        {
          on = [
            "c"
            "a"
          ];
          run = "plugin compress";
          desc = "Compress selected files (archive)";
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
            "C"
            "P"
          ];
          run = "plugin pandoc";
          desc = "Pandoc: convert document";
        }
        {
          on = [
            "C"
            "p"
          ];
          run = "plugin convert -- --extension=png";
          desc = "Convert image to PNG";
        }
        {
          on = [
            "C"
            "j"
          ];
          run = "plugin convert -- --extension=jpg";
          desc = "Convert image to JPG";
        }
        {
          on = [
            "C"
            "w"
          ];
          run = "plugin convert -- --extension=webp";
          desc = "Convert image to WebP";
        }
        {
          on = [
            "m"
            "b"
          ];
          run = "plugin whoosh jump_by_fzf";
          desc = "Bookmarks: jump (fzf)";
        }
        {
          on = [
            "m"
            "j"
          ];
          run = "plugin whoosh jump_by_key";
          desc = "Bookmarks: jump (menu by key)";
        }
        {
          on = [
            "m"
            "a"
          ];
          run = "plugin whoosh save";
          desc = "Bookmarks: add hovered";
        }
        {
          on = [
            "m"
            "A"
          ];
          run = "plugin whoosh save_cwd";
          desc = "Bookmarks: add current directory";
        }
        {
          on = [
            "m"
            "t"
          ];
          run = "plugin whoosh save_temp";
          desc = "Bookmarks: add hovered (temporary)";
        }
        {
          on = [
            "m"
            "T"
          ];
          run = "plugin whoosh save_cwd_temp";
          desc = "Bookmarks: add cwd (temporary)";
        }
        {
          on = [
            "m"
            "d"
          ];
          run = "plugin whoosh delete_by_fzf";
          desc = "Bookmarks: delete (fzf, TAB multi-select)";
        }
        {
          on = [
            "m"
            "r"
          ];
          run = "plugin whoosh rename_by_fzf";
          desc = "Bookmarks: rename (fzf)";
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
          desc = "Maximize/restore preview pane";
        }
        # Tabs
        {
          on = [
            "<Tab>"
            "<Tab>"
          ];
          run = "tab_create --current";
          desc = "New tab (CWD)";
        }
        {
          on = [
            "<Tab>"
            "d"
          ];
          run = "close";
          desc = "Close tab";
        }
        {
          on = [
            "<Tab>"
            "]"
          ];
          run = "tab_switch 1 --relative";
          desc = "Next tab";
        }
        {
          on = [
            "<Tab>"
            "["
          ];
          run = "tab_switch -1 --relative";
          desc = "Previous tab";
        }
        {
          on = [
            "<Tab>"
            "f"
          ];
          run = "tab_switch 0";
          desc = "First tab";
        }
        {
          on = [
            "<Tab>"
            "<"
          ];
          run = "tab_swap -1";
          desc = "Move tab left";
        }
        {
          on = [
            "<Tab>"
            ">"
          ];
          run = "tab_swap 1";
          desc = "Move tab right";
        }
        {
          on = "K";
          run = "tab_switch 1 --relative";
          desc = "Next tab";
        }
        {
          on = "J";
          run = "tab_switch -1 --relative";
          desc = "Previous tab";
        }
        {
          on = "i";
          run = "spot";
          desc = "Spot file info";
        }
        # Disabled default tab bindings (moved to <Tab> prefix / J / K)
        {
          on = [
            "t"
            "t"
          ];
          run = "noop";
          desc = "(disabled — moved to <Tab><Tab>)";
        }
        {
          on = [
            "t"
            "r"
          ];
          run = "noop";
          desc = "(disabled — tab_rename unused)";
        }
        {
          on = "[";
          run = "noop";
          desc = "(disabled — moved to <Tab>[ / J)";
        }
        {
          on = "]";
          run = "noop";
          desc = "(disabled — moved to <Tab>] / K)";
        }
        {
          on = "{";
          run = "noop";
          desc = "(disabled — moved to <Tab><)";
        }
        {
          on = "}";
          run = "noop";
          desc = "(disabled — moved to <Tab>>)";
        }
      ];
    };
}
