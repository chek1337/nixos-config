{ pkgs, ... }:
let
  # nixpkgs ships just-nvim @ 1.0.0, which still hard-requires telescope at
  # load time. Telescope was dropped on master (now uses vim.ui.select), so
  # build from the pinned master commit instead.
  just-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "just-nvim";
    version = "2026-05-15";
    src = pkgs.fetchFromGitHub {
      owner = "nxuv";
      repo = "just.nvim";
      rev = "587cc281734c85c8765e475fb12b328d335b442b";
      hash = "sha256-q2qlPbpx6YHvgWXUvzZlUmESFJgHM7TtsHAwuzd6iws=";
    };
    dependencies = [ pkgs.vimPlugins.plenary-nvim ];
  };
in
{
  extraPackages = [ pkgs.just ];

  plugins.fidget = {
    enable = true;
    lazyLoad.settings.event = "LspAttach";
  };

  # plenary.nvim — общая библиотека (telescope и др.), остаётся в pack/start/.
  # just-nvim уходит в pack/opt/ и грузится по `:Just*` командам.
  extraPlugins = [
    pkgs.vimPlugins.plenary-nvim
    {
      plugin = just-nvim;
      optional = true;
    }
  ];

  plugins.lz-n.plugins = [
    {
      __unkeyed-1 = "just-nvim";
      cmd = [
        "Just"
        "JustSelect"
        "JustStop"
        "JustCreateTemplate"
      ];
      after = # lua
        ''
          function()
            require("just").setup({
              open_qf_on_error = true,
              open_qf_on_run = false,
              autoscroll_qf = true,
              register_commands = true,
            })
          end
        '';
    }
  ];

  keymaps = [
    {
      key = "<leader>jj";
      mode = "n";
      action = "<cmd>Just<cr>";
      options.desc = "Run default task";
    }
    {
      key = "<leader>js";
      mode = "n";
      action = "<cmd>JustSelect<cr>";
      options.desc = "Select task";
    }
    {
      key = "<leader>jk";
      mode = "n";
      action = "<cmd>JustStop<cr>";
      options.desc = "Stop running task";
    }
    {
      key = "<leader>jt";
      mode = "n";
      action = "<cmd>JustCreateTemplate<cr>";
      options.desc = "Create justfile template";
    }
    {
      key = "<leader>jq";
      mode = "n";
      action = "<cmd>copen<cr>";
      options.desc = "Open quickfix";
    }
  ];
}
