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
    # init.lua does `require("plenary.job")` at load; the require-check needs it.
    dependencies = [ pkgs.vimPlugins.plenary-nvim ];
  };
in
{
  vim = {
    # `just` itself must be on PATH for the plugin to run any task.
    extraPackages = [ pkgs.just ];

    # plenary-nvim is already declared by harpoon.nix; we only depend on it.
    extraPlugins = with pkgs.vimPlugins; {
      # Task progress spinner — just.nvim picks it up via can_load("fidget").
      fidget-nvim = {
        package = fidget-nvim;
        setup = ''require("fidget").setup({})'';
      };

      just-nvim = {
        package = just-nvim;
        after = [
          "plenary-nvim"
          "fidget-nvim"
        ];
        setup = # lua
          ''
            require("just").setup({
              open_qf_on_error = true,  -- pop quickfix when a task fails
              open_qf_on_run = false,   -- don't steal focus for `:JustRun`
              autoscroll_qf = true,     -- follow task output live
              register_commands = true, -- :Just, :JustSelect, :JustStop, ...
            })
          '';
      };
    };

    keymaps = [
      {
        key = "<leader>jj";
        mode = [ "n" ];
        action = "<cmd>Just<cr>";
        desc = "Run default task";
      }
      {
        key = "<leader>js";
        mode = [ "n" ];
        action = "<cmd>JustSelect<cr>";
        desc = "Select task";
      }
      {
        key = "<leader>jk";
        mode = [ "n" ];
        action = "<cmd>JustStop<cr>";
        desc = "Stop running task";
      }
      {
        key = "<leader>jt";
        mode = [ "n" ];
        action = "<cmd>JustCreateTemplate<cr>";
        desc = "Create justfile template";
      }
      {
        key = "<leader>jq";
        mode = [ "n" ];
        action = "<cmd>copen<cr>";
        desc = "Open quickfix";
      }
    ];
  };
}
