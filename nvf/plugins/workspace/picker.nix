{ ... }:
{
  # Override snacks.picker keymaps so that "Root Dir" scopes search to the
  # active workspace folders. Falls back to default cwd/root_dir when no
  # workspace is loaded. Cwd-explicit variants (<leader>fF, <leader>sG,
  # <leader>sW) defined in plugins/snacks/picker.nix are left untouched.
  vim.luaConfigRC.workspace-picker-overrides = # lua
    ''
      local function ws_dirs()
        local ok, ws = pcall(require, "chek.workspace")
        if not ok then return nil end
        local f = ws.current()
        if #f == 0 then return nil end
        return f
      end

      local ROOT_MARKERS = {
        -- Generic / VCS
        ".git",

        -- Nix
        "flake.nix",

        -- Rust
        "Cargo.toml", "Cargo.lock", "rust-project.json",

        -- Go
        "go.work", "go.mod",

        -- Python
        "pyproject.toml", "Pipfile", "requirements.txt",
        "setup.cfg", "setup.py", "pyrightconfig.json",

        -- JS / TS / Web
        "package.json", "tsconfig.json", "jsconfig.json",

        -- PHP
        "composer.json", ".phpactor.json", ".phpactor.yml",

        -- Java / JVM
        "build.gradle", "build.gradle.kts", "settings.gradle",
        "settings.gradle.kts", "pom.xml", "build.xml",

        -- C / C++
        "compile_commands.json", "compile_flags.txt", "configure.ac",
        ".clangd", ".clang-tidy", ".clang-format",

        -- CMake
        "CMakeLists.txt", ".gersemirc",

        -- Lua
        ".luarc.json", ".luarc.jsonc", ".luacheckrc",
        ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml",

        -- Make / Just
        "Makefile", "GNUmakefile", "Justfile", "justfile",
      }

      local function buf_root()
        local f = vim.api.nvim_buf_get_name(0)
        if f == "" or vim.bo.buftype ~= "" then return nil end
        return vim.fs.root(f, ROOT_MARKERS)
      end

      local function with_dirs(extra)
        extra = extra or {}
        local d = ws_dirs()
        if d then
          return vim.tbl_extend("force", extra, { dirs = d })
        end
        local r = buf_root()
        if r then
          return vim.tbl_extend("force", extra, { cwd = r })
        end
        return extra
      end

      vim.keymap.set("n", "<leader>ff", function()
        require("snacks").picker.files(with_dirs())
      end, { desc = "Find Files (Workspace/Root)" })

      vim.keymap.set("n", "<leader>fr", function()
        require("snacks").picker.recent(with_dirs())
      end, { desc = "Recent (Workspace/Root)" })

      vim.keymap.set("n", "<leader>sg", function()
        require("snacks").picker.grep(with_dirs())
      end, { desc = "Grep (Workspace/Root)" })

      vim.keymap.set({ "n", "x" }, "<leader>sw", function()
        require("snacks").picker.grep_word(with_dirs())
      end, { desc = "Grep Word (Workspace/Root)" })
    '';
}
