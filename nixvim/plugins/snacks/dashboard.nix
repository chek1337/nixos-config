{ ... }:
{
  plugins.web-devicons.enable = true;

  plugins.snacks.settings.dashboard = {
    enabled = true;
    preset.header.__raw = ''
            [[
                                                                          
            ████ ██████           █████      ██                     
           ███████████             █████                             
           █████████ ███████████████████ ███   ███████████   
          █████████  ███    █████████████ █████ ██████████████   
         █████████ ██████████ █████████ █████ █████ ████ █████   
       ███████████ ███    ███ █████████ █████ █████ ████ █████  
      ██████  █████████████████████ ████ █████ █████ ████ ██████ ]]
    '';
    # Default `s` button binds via section = "session", but snacks resolves
    # that through lazy.nvim's plugin list, which is absent under nixvim —
    # wire persistence.nvim directly.
    preset.keys.__raw = ''
      {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      }            
    '';
    sections = [
      { section = "header"; }
      {
        icon = " ";
        title = "Keymaps";
        section = "keys";
        indent = 2;
        padding = 1;
      }
      {
        icon = " ";
        title = "Recent Files";
        section = "recent_files";
        indent = 2;
        padding = 1;
      }
      {
        icon = " ";
        title = "Projects";
        section = "projects";
        indent = 2;
        padding = 1;
      }
    ];
  };
}
