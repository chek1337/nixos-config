{
  flake.modules.homeManager.yazi-tv-grep-router =
    { pkgs-unstable, ... }:
    {
      programs.yazi.plugins.tv-grep-router = pkgs-unstable.writeTextDir "main.lua" ''
        local M = {}

        local get_cwd = ya.sync(function()
          return tostring(cx.active.current.cwd)
        end)

        function M:entry()
          if os.getenv("NVIM_CWD") then
            local cwd = get_cwd()
            local esc = cwd:gsub("\\", "\\\\"):gsub('"', '\\"')
            local json = string.format('{"cwd":"%s"}', esc)
            -- Publish only; nvim side closes the yazi buffer.
            -- Quitting from here would race with our own plugin task
            -- and pop yazi's "unfinished tasks" prompt.
            Command("ya")
              :arg("pub-to"):arg("0")
              :arg("yazi-nvim-grep-cwd")
              :arg("--json"):arg(json)
              :spawn():wait()
            return
          end

          ya.emit("plugin", {
            "television",
            [[text --tv-no-remote --tv-keybindings='enter="confirm_selection"' --pattern='^([^:]+):(%d+):' --pattern-keys=file,line --reveal='{{%file}}' --shell='nvim {{$%file}} +{{line}}']],
          })
        end

        return M
      '';
    };
}
