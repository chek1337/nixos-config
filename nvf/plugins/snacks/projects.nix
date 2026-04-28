{ ... }:
{
  vim.luaConfigRC.snacks-projects = # lua
    ''
      local M = {}

      local function path(item) return item.file or item.text end

      function M.confirm_tab(picker, item)
        local items = picker:selected({ fallback = true })
        picker:close()
        for _, it in ipairs(items) do
          vim.cmd.tabnew()
          vim.cmd.tcd(path(it))
        end
      end

      function M.yank(_, item)
        if not item then return end
        local p = path(item)
        vim.fn.setreg("+", p)
        vim.notify("[projects] yanked: " .. p)
      end

      M.PATTERNS = {
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

      M.DEV = { "~/dev", "~/projects", "~/code", "~/nixos-config" }

      local IN_PICKER_KEYS = {
        ["<c-y>"] = { M.yank,                       mode = { "n", "i" } },
        ["<c-f>"] = { { "tcd", "picker_files" },    mode = { "n", "i" } },
        ["<c-g>"] = { { "tcd", "picker_grep" },     mode = { "n", "i" } },
        ["<c-e>"] = { { "tcd", "picker_explorer" }, mode = { "n", "i" } },
        ["<c-r>"] = { { "tcd", "picker_recent" },   mode = { "n", "i" }, nowait = true },
        -- terminal sends <c-w> on Backspace; snacks projects picker maps <c-w> to tcd by default
        -- ["<c-w>"] = false,
      }

      function M.opts(extra)
        return vim.tbl_deep_extend("force", {
          dev      = M.DEV,
          patterns = M.PATTERNS,
          confirm  = { "tcd" },
          win = { input = { keys = IN_PICKER_KEYS } },
        }, extra or {})
      end

      function M.zoxide_opts(extra)
        return vim.tbl_deep_extend("force", {
          confirm = { "tcd" },
          win = { input = { keys = IN_PICKER_KEYS } },
        }, extra or {})
      end

      function M.show()
        local f = vim.api.nvim_buf_get_name(0)
        local root
        if f ~= "" and vim.bo.buftype == "" then
          root = vim.fs.root(f, M.PATTERNS)
        end
        local tab_local = vim.fn.haslocaldir(0, 0) == 1
        vim.notify(table.concat({
          "Buffer root: " .. (root or "<none>"),
          "CWD:         " .. vim.fn.getcwd(),
          "Tab CWD:     " .. (tab_local and vim.fn.getcwd(0, 0) or "<inherits>"),
        }, "\n"))
      end

      package.loaded["chek.snacks_projects"] = M
    '';

  vim.binds.whichKey.register."<leader>p" = "Projects (snacks) alpha ver";

  vim.keymaps = [
    {
      key = "<leader>pp";
      mode = [ "n" ];
      action = "function() require('snacks').picker.projects(require('chek.snacks_projects').opts()) end";
      lua = true;
      desc = "Projects";
    }
    {
      key = "<leader>pz";
      mode = [ "n" ];
      action = "function() require('snacks').picker.zoxide(require('chek.snacks_projects').zoxide_opts()) end";
      lua = true;
      desc = "Zoxide";
    }
    {
      key = "<leader>pP";
      mode = [ "n" ];
      action = "function() local m = require('chek.snacks_projects'); require('snacks').picker.projects(m.opts({ confirm = m.confirm_tab })) end";
      lua = true;
      desc = "Projects (new tab)";
    }
    {
      key = "<leader>pZ";
      mode = [ "n" ];
      action = "function() local m = require('chek.snacks_projects'); require('snacks').picker.zoxide(m.zoxide_opts({ confirm = m.confirm_tab })) end";
      lua = true;
      desc = "Zoxide (new tab)";
    }
    {
      key = "<leader>pd";
      mode = [ "n" ];
      action = "function() require('chek.snacks_projects').show() end";
      lua = true;
      desc = "Project info";
    }
  ];
}
