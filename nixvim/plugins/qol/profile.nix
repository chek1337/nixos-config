{ pkgs, ... }:
let
  profile-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "profile.nvim";
    version = "unstable-2025-03-05";
    src = pkgs.fetchFromGitHub {
      owner = "stevearc";
      repo = "profile.nvim";
      rev = "30433d7513f0d14665c1cfcea501c90f8a63e003";
      hash = "sha256-2Mk6VbC+K/WhTWF+yHyDhQKJhTi2rpo8VJsnO7ofHXs=";
    };
  };
in
{
  # stevearc/profile.nvim — рантайм-флеймграф для nvim.
  #
  # Активируется переменной окружения NVIM_PROFILE, чтобы инструментация
  # не висела на «холодных» сессиях (она дешёвая, но не бесплатная):
  #   NVIM_PROFILE=1     — instrument_autocmds + instrument("*"),
  #                        запись запускается вручную по <leader>P.
  #   NVIM_PROFILE=start — то же + сразу start("*"), полезно для
  #                        профайлинга самого старта nvim.
  #
  # <leader>P — toggle: либо start("*"), либо stop() + спрос пути для
  # экспорта Chrome trace. Открывать в https://ui.perfetto.dev.
  extraPlugins = [ profile-nvim ];

  extraConfigLuaPre = ''
    do
      local mode = os.getenv("NVIM_PROFILE")
      if mode then
        local prof = require("profile")
        prof.instrument_autocmds()
        if mode:lower():match("^start") then
          prof.start("*")
        else
          prof.instrument("*")
        end
      end
    end
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>P";
      action.__raw = ''
        function()
          local ok, prof = pcall(require, "profile")
          if not ok then
            vim.notify("profile.nvim: set NVIM_PROFILE=1 and restart nvim", vim.log.levels.WARN)
            return
          end
          if prof.is_recording() then
            prof.stop()
            vim.ui.input(
              { prompt = "Save profile to: ", completion = "file", default = "/tmp/nvim-profile.json" },
              function(filename)
                if filename and filename ~= "" then
                  prof.export(filename)
                  vim.notify("profile.nvim: wrote " .. filename)
                end
              end
            )
          else
            prof.start("*")
            vim.notify("profile.nvim: recording…")
          end
        end
      '';
      options.desc = "Profile: toggle recording";
    }
  ];
}
