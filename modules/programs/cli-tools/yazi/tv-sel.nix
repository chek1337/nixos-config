{
  flake.modules.homeManager.yazi-tv-sel =
    { pkgs, ... }:
    {
      programs.yazi.plugins.tv-sel = pkgs.writeTextDir "main.lua" ''
        local M = {}

        local get_state = ya.sync(function()
          local sel = {}
          for _, url in pairs(cx.active.selected) do
            sel[#sel + 1] = tostring(url)
          end
          return { selected = sel, cwd = tostring(cx.active.current.cwd) }
        end)

        function M:entry()
          local state = get_state()

          if #state.selected == 0 then
            ya.notify({
              title = "tv-sel",
              content = "No files selected",
              level = "warn",
              timeout = 3,
            })
            return
          end

          if os.getenv("NVIM_CWD") then
            local parts = {}
            for _, f in ipairs(state.selected) do
              local esc = f:gsub("\\", "\\\\"):gsub('"', '\\"')
              parts[#parts + 1] = '"' .. esc .. '"'
            end
            local json = '{"files":[' .. table.concat(parts, ",") .. ']}'
            Command("ya")
              :arg("pub-to"):arg("0")
              :arg("yazi-nvim-grep-selected")
              :arg("--json"):arg(json)
              :spawn():wait()
            ya.emit("quit", {})
            return
          end

          local tmp_list = "/tmp/yazi-sel-grep-files-" .. (os.getenv("USER") or "user")
          local lf = io.open(tmp_list, "w")
          for _, f in ipairs(state.selected) do
            lf:write(f .. "\n")
          end
          lf:close()

          local cfg_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/television/cable"
          os.execute("mkdir -p " .. cfg_dir)
          local cf = io.open(cfg_dir .. "/yazi-sel-grep.toml", "w")
          cf:write(string.format([[
        [metadata]
        name = "yazi-sel-grep"
        description = "Grep in yazi-selected files"
        requirements = ["rg", "bat"]

        [source]
        command = "xargs -d '\\n' -a %s rg . --with-filename --no-heading --line-number --colors 'match:fg:white' --colors 'path:fg:blue' --color=always"
        ansi = true
        display = "{strip_ansi|split:\\::2..}"
        output = "{strip_ansi|split:\\::..2}"

        [preview]
        command = "bat -n --color=always --highlight-line '{strip_ansi|split:\\::1}' '{strip_ansi|split:\\::0}'"
        env = { BAT_THEME = "ansi" }
        offset = '{strip_ansi|split:\\::1}'

        [ui.preview_panel]
        header = "{strip_ansi|split:\\::..2}"
        ]], tmp_list))
          cf:close()

          local tmp_out = os.tmpname()
          local permit = ui.hide()
          local child = Command("sh")
            :arg("-c")
            :arg(string.format(
              [[tv --no-remote --keybindings='enter="confirm_selection"' yazi-sel-grep > %s]],
              ya.quote(tmp_out)
            ))
            :cwd(state.cwd)
            :stdin(Command.INHERIT)
            :stdout(Command.INHERIT)
            :stderr(Command.INHERIT)
            :spawn()
          if child then child:wait() end
          permit:drop()

          local of = io.open(tmp_out, "r")
          if not of then return end
          local line = of:read("*all"):gsub("[\r\n]+$", "")
          of:close()
          os.remove(tmp_out)
          if line == "" then return end

          local file, row = line:match("^(.+):(%d+)$")
          if not file then return end

          permit = ui.hide()
          local nv = Command("sh")
            :arg("-c")
            :arg(string.format("nvim %s +%s", ya.quote(file), row))
            :cwd(state.cwd)
            :stdin(Command.INHERIT)
            :stdout(Command.INHERIT)
            :stderr(Command.INHERIT)
            :spawn()
          if nv then nv:wait() end
          permit:drop()

          ya.emit("reveal", { Url(file), raw = true })
        end

        return M
      '';
    };
}
