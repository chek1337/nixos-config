{
  pkgs,
  lib,
  config,
  ...
}:
let
  themes = {
    nord = import ./nord { inherit pkgs; };
    catppuccin-mocha = import ./catppuccin-mocha { inherit pkgs; };
    gruvbox-dark-hard = import ./gruvbox-dark-hard { inherit pkgs; };
    ilyasyoy-monochrome-dark = import ./ilyasyoy-monochrome {
      inherit pkgs;
      background = "dark";
    };
    ilyasyoy-monochrome-light = import ./ilyasyoy-monochrome {
      inherit pkgs;
      background = "light";
    };
  };

  # Lua dispatch table + runtime theme file reader for colorScheme = "dynamic".
  # Theme is stored in ~/.local/share/nvim/theme; changed via :Theme <name>.
  dynamicLua =
    let
      mkEntry = name: theme: ''
        ["${name}"] = function()
          ${theme.setup}
        end,
      '';
      themeTable = lib.concatStrings (lib.mapAttrsToList mkEntry themes);
    in
    # lua
    ''
      local _theme_file = vim.fn.expand("~/.local/share/nvim/theme")
      local _theme_setup = {
        ${themeTable}
      }
      local function _get_theme()
        if vim.fn.filereadable(_theme_file) == 1 then
          local f = io.open(_theme_file, "r")
          if f then
            local t = f:read("*l")
            f:close()
            if t then return (t:gsub("^%s*(.-)%s*$", "%1")) end
          end
        end
        return "nord"
      end
      local function _apply_theme(name)
        local fn = _theme_setup[name]
        if fn then
          fn()
        else
          vim.notify("nvim: unknown theme '" .. name .. "', using nord", vim.log.levels.WARN)
          _theme_setup["nord"]()
        end
      end
      _apply_theme(_get_theme())
      vim.api.nvim_create_user_command("Themes", function(opts)
        local name = opts.args
        if not _theme_setup[name] then
          vim.notify("Unknown theme: " .. name, vim.log.levels.ERROR)
          return
        end
        local f = io.open(_theme_file, "w")
        if f then f:write(name .. "\n"); f:close() end
        _apply_theme(name)
      end, {
        nargs = 1,
        complete = function()
          local names = {}
          for k in pairs(_theme_setup) do names[#names + 1] = k end
          return names
        end,
      })
    '';
in
{
  options.colorScheme = lib.mkOption {
    type = lib.types.str;
    default = "nord";
    description = ''
      Colorscheme name; controls which theme module loads.
      Use "dynamic" to enable runtime switching via :Theme <name> and
      persistence in ~/.local/share/nvim/theme.
    '';
  };

  config = lib.mkMerge [
    (lib.mkMerge (
      lib.mapAttrsToList (
        name: theme:
        lib.mkIf (config.colorScheme == name) {
          extraPlugins = [ theme.package ];
          extraConfigLua = theme.setup;
        }
      ) themes
    ))
    (lib.mkIf (config.colorScheme == "dynamic") {
      # All theme packages compiled in; Lua picks one at runtime.
      extraPlugins = lib.unique (lib.mapAttrsToList (_: t: t.package) themes);
      extraConfigLua = dynamicLua;
    })
  ];
}
