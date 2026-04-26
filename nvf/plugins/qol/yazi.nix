{ ... }:

{
  vim.utility.yazi-nvim = {
    enable = true;

    mappings = {
      openYazi = "<leader>e";
      openYaziDir = "<leader>E";
    };

    setupOpts = {
      open_for_directories = true;
      yazi_floating_window_scaling_factor = 1;
      yazi_floating_window_border = "none";
      forwarded_dds_events = [
        "yazi-nvim-grep-cwd"
        "yazi-nvim-grep-selected"
      ];
      integrations = {
        grep_in_directory = "snacks.picker";
        grep_in_selected_files = "snacks.picker";
      };
    };
  };

  vim.luaConfigRC.yazi-grep-router = # lua
    ''
      vim.api.nvim_create_autocmd("User", {
        pattern = "YaziDDSCustom",
        group = vim.api.nvim_create_augroup("YaziGrepRouter", { clear = true }),
        callback = function(event)
          local function start_insert()
            vim.cmd("startinsert")
          end

          if event.data.type == "yazi-nvim-grep-cwd" then
            local data = vim.json.decode(event.data.raw_data or "{}")
            local cwd = data.cwd or vim.uv.cwd()
            vim.defer_fn(function()
              require("snacks.picker").grep({
                title = "Grep in " .. vim.fn.fnamemodify(cwd, ":~:."),
                dirs = { cwd },
                on_show = start_insert,
              })
            end, 100)
          elseif event.data.type == "yazi-nvim-grep-selected" then
            local data = vim.json.decode(event.data.raw_data or "{}")
            local files = data.files or {}
            if #files == 0 then return end
            vim.defer_fn(function()
              require("snacks.picker").grep({
                title = string.format("Grep in %d paths", #files),
                dirs = files,
                on_show = start_insert,
              })
            end, 100)
          end
        end,
      })
    '';
}
