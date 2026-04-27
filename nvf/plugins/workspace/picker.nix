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

      local function with_dirs(extra)
        local d = ws_dirs()
        if not d then return extra or {} end
        local opts = vim.tbl_extend("force", extra or {}, { dirs = d })
        return opts
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
