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
      integrations = {
        grep_in_directory = "snacks.picker";
        grep_in_selected_files = "snacks.picker";
      };
    };
  };
}
