--- @since 26.1.22
--- Forked from https://github.com/DreamMaoMao/fg.yazi
local get_cwd = ya.sync(function() return cx.active.current.cwd end)

local function fail(s, ...)
  ya.notify({ title = "search.yazi", content = string.format(s, ...), timeout = 5, level = "error" })
end

local function is_directory(filepath)
  local child = Command("test"):arg({ "-d", filepath }):spawn()
  local output = child:wait_with_output()
  return output and output.status.code == 0
end

local function is_text_file(filepath)
  local child = Command("file"):arg({ "--mime-type", "-b", filepath }):stdout(Command.PIPED):spawn()
  if not child then
    return true
  end
  local output = child:wait_with_output()
  if not output then
    return true
  end
  local mime = output.stdout:gsub("%s+$", "")
  return mime:find("^text/") ~= nil
end

local function parse_line(line)
  -- format: path:row:content
  local relative_path, row = line:match("^(.-):(%d+):")
  return relative_path, row
end

local function build_ignores(dirs)
  local rg, fd = "", ""
  for _, d in ipairs(dirs) do
    rg = rg .. " -g '!" .. d .. "'"
    fd = fd .. " --exclude '" .. d .. "'"
  end
  local grep = "(" .. table.concat(dirs, "|") .. ")"
  return rg, fd, grep
end

local ignore_dirs = { ".git", "node_modules", ".direnv" }
local rg_ignores, fd_ignores, grep_ignores = build_ignores(ignore_dirs)

local rg_base_command = " rg --hidden" .. rg_ignores .. " --no-heading --smart-case --line-number --color=always "
local fzf_base_command = " fzf --no-multi --height 90% --margin 2% --padding 1% --border sharp --ansi "
local fzf_bat_preview_command = " --preview 'fzf-bat-preview {1} {2}' "
local bat_preview_command =
  " --preview='if [ -d {} ]; then eza -1 --icons --color=always --icons {} || ls -la --color=always {}; else bat --theme=\"Visual Studio Dark+\" --color=always {}; fi' "

local function entry(_, job)
  local args = job.args
  local _permit = ui.hide()
  local cwd = get_cwd()
  local shell_value = os.getenv("SHELL"):match(".*/(.*)")
  local cmd_args = ""

  if tostring(cwd) == os.getenv("HOME") and args[1] ~= "fzf_locate" then
    return fail("Searching from home is not allowed")
  end

  if args[1] == "fzf_content" then
    local rg_fzf_prefix = rg_base_command .. " --colors 'match:none' --colors 'match:fg:white' --colors 'match:style:bold' "
    local toggle_bind = string.format(
      "--bind='ctrl-s:transform:[[ ! $FZF_PROMPT =~ rg ]] && "
        .. [[echo "rebind(change)+change-prompt(rg> )+disable-search+clear-query+reload(%s {q} || true)" || ]]
        .. [[echo "unbind(change)+change-prompt(fzf> )+enable-search+clear-query"']],
      rg_base_command
    )

    cmd_args = [[
    INITIAL_QUERY="${1:-.}"
    eval "]] .. rg_fzf_prefix .. [[ \"\$INITIAL_QUERY\"" | ]] .. fzf_base_command .. [[ \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --bind "start:unbind(change)" \
      --bind "change:reload:sleep 0.1; ]] .. rg_base_command .. [[ {q} || true" \
      --prompt 'fzf> ' \
      --delimiter : \
      ]] .. toggle_bind .. [[ \
      ]] .. fzf_bat_preview_command .. [[
  ]]
  end

  if args[1] == "fzf_filename" then
    local search_command = "fd --color=always --follow --hidden --no-ignore-vcs" .. fd_ignores
    local fzf_command = fzf_base_command .. bat_preview_command
    cmd_args = search_command .. " | " .. fzf_command
  end

  if args[1] == "ripgrep_content" then
    local toggle_bind = string.format(
      "--bind='ctrl-s:transform:[[ ! $FZF_PROMPT =~ rg ]] && "
        .. [[echo "rebind(change)+change-prompt(rg> )+disable-search+clear-query+reload(%s {q} || true)" || ]]
        .. [[echo "unbind(change)+change-prompt(fzf> )+enable-search+clear-query"']],
      rg_base_command
    )

    cmd_args = [[
    INITIAL_QUERY="${*:-}"
    FZF_DEFAULT_COMMAND="]] .. rg_base_command .. [[ $(printf %q "$INITIAL_QUERY")" \
      ]] .. fzf_base_command .. [[ \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --disabled --query "$INITIAL_QUERY" \
      --bind "change:reload:sleep 0.1; ]] .. rg_base_command .. [[ {q} || true" \
      --prompt 'rg> ' \
      --delimiter : \
      ]] .. toggle_bind .. [[ \
      ]] .. fzf_bat_preview_command .. [[
  ]]
  end

  if args[1] == "fzf_locate" then
    cmd_args = "plocate home | grep -vE '" .. grep_ignores .. "' | "
      .. fzf_base_command
      .. " --info hidden "
      .. bat_preview_command
  end

  local child, err = Command(shell_value)
    :arg({ "-c", cmd_args })
    :cwd(tostring(cwd))
    :stdin(Command.INHERIT)
    :stdout(Command.PIPED)
    :stderr(Command.INHERIT)
    :spawn()

  if not child then
    return fail("Spawning `search.yazi` failed with error code %s. Do you have it installed?", err)
  end

  local output, err = child:wait_with_output()
  if not output then
    return fail("Cannot read `search.yazi` output, error code %s", err)
  elseif output.status.code == 130 then -- Ctrl-C/Esc
    return
  elseif output.status.code == 1 then -- no match
    return ya.notify({ title = "search.yazi", content = "No file selected", timeout = 5 })
  elseif output.status.code ~= 0 then
    return fail("`search.yazi` exited with error code %s", output.status.code)
  end

  local target = output.stdout:gsub("\n$", "")
  if target == "" then
    return
  end

  if args[1] == "fzf_content" or args[1] == "ripgrep_content" then
    local relative_path, row = parse_line(target)
    if relative_path and row then
      local absolute_path = cwd:join(Url(relative_path))
      local absolute_path_str = tostring(absolute_path)
      ya.emit("reveal", { absolute_path })
      local command = "nvim +" .. row .. " " .. ya.quote(absolute_path_str)
      ya.emit("shell", { block = true, command })
    end
  end

  if args[1] == "fzf_filename" or args[1] == "fzf_locate" then
    local absolute_path = cwd:join(Url(target))
    local absolute_path_str = tostring(absolute_path)
    if is_directory(absolute_path_str) then
      ya.emit("cd", { absolute_path })
    else
      ya.emit("reveal", { absolute_path })
      if is_text_file(absolute_path_str) then
        local command = "nvim " .. ya.quote(absolute_path_str)
        ya.emit("shell", { block = true, command })
      end
    end
  end

end

local function setup(state, opts) end
return { entry = entry, setup = setup }
