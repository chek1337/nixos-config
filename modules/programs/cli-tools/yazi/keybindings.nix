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
            "s"
            "g"
          ];
          run = ''plugin television -- text --tv-no-remote --tv-keybindings='enter="confirm_selection"' --pattern='^([^:]+):(%d+):' --pattern-keys=file,line --reveal='{{%file}}' --shell='nvim {{$%file}} +{{line}}' '';
          desc = "Grep text (television)";
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
          on = "y";
          run = "plugin ucp copy notify";
          desc = "Copy to system clipboard (ucp)";
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
          on = "<A-y>";
          run = "plugin copy-file-contents";
          desc = "Copy file contents to clipboard";
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
          on = "M";
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
            "p"
          ];
          run = "plugin pandoc";
          desc = "Pandoc: convert document";
        }
        {
          on = [
            "i"
            "p"
          ];
          run = "plugin convert -- --extension=png";
          desc = "Convert image to PNG";
        }
        {
          on = [
            "i"
            "j"
          ];
          run = "plugin convert -- --extension=jpg";
          desc = "Convert image to JPG";
        }
        {
          on = [
            "i"
            "w"
          ];
          run = "plugin convert -- --extension=webp";
          desc = "Convert image to WebP";
        }
      ];
    };
}
