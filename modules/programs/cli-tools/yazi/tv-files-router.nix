{
  flake.modules.homeManager.yazi-tv-files-router =
    { pkgs, ... }:
    {
      programs.yazi.plugins.tv-files-router = pkgs.writeTextDir "main.lua" ''
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
              :arg("yazi-nvim-files-cwd")
              :arg("--json"):arg(json)
              :spawn():wait()
            return
          end

          ya.emit("plugin", { "television", "files" })
        end

        return M
      '';
    };
}
