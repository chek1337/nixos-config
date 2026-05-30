{ ... }:
{
  keymaps = [
    # Basic motions (n/x/o)
    {
      key = "р";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "h";
      options.desc = "Left (RU)";
    }
    {
      key = "о";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "j";
      options.desc = "Down (RU)";
    }
    {
      key = "л";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "k";
      options.desc = "Up (RU)";
    }
    {
      key = "д";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "l";
      options.desc = "Right (RU)";
    }
    {
      key = "ц";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "w";
      options.desc = "Word forward (RU)";
    }
    {
      key = "Ц";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "W";
      options.desc = "WORD forward (RU)";
    }
    {
      key = "и";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "b";
      options.desc = "Word backward (RU)";
    }
    {
      key = "И";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "B";
      options.desc = "WORD backward (RU)";
    }
    {
      key = "у";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "e";
      options.desc = "End of word (RU)";
    }
    {
      key = "У";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "E";
      options.desc = "End of WORD (RU)";
    }
    {
      key = "пп";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "gg";
      options.desc = "Top of file (RU)";
    }
    {
      key = "П";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "G";
      options.desc = "End of file (RU)";
    }

    # Mode-entry commands
    {
      key = "ш";
      mode = "n";
      action = "i";
      options.desc = "Insert (RU)";
    }
    {
      key = "Ш";
      mode = "n";
      action = "I";
      options.desc = "Insert at line start (RU)";
    }
    {
      key = "ф";
      mode = "n";
      action = "a";
      options.desc = "Append (RU)";
    }
    {
      key = "Ф";
      mode = "n";
      action = "A";
      options.desc = "Append at line end (RU)";
    }
    {
      key = "м";
      mode = "n";
      action = "v";
      options.desc = "Visual (RU)";
    }
    {
      key = "М";
      mode = "n";
      action = "V";
      options.desc = "Visual line (RU)";
    }
    {
      key = "щ";
      mode = "n";
      action = "o";
      options.desc = "Open line below (RU)";
    }
    {
      key = "Щ";
      mode = "n";
      action = "O";
      options.desc = "Open line above (RU)";
    }
  ];
}
