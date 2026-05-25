{ ... }:
{
  plugins.dap.enable = true;
  plugins.dap-ui.enable = true;
  plugins.dap-virtual-text.enable = true;

  keymaps = [
    {
      key = "<leader>db";
      mode = "n";
      action.__raw = "function() require('dap').toggle_breakpoint() end";
      options.desc = "DAP: Toggle Breakpoint";
    }
    {
      key = "<leader>dc";
      mode = "n";
      action.__raw = "function() require('dap').continue() end";
      options.desc = "DAP: Continue";
    }
    {
      key = "<leader>di";
      mode = "n";
      action.__raw = "function() require('dap').step_into() end";
      options.desc = "DAP: Step Into";
    }
    {
      key = "<leader>do";
      mode = "n";
      action.__raw = "function() require('dap').step_over() end";
      options.desc = "DAP: Step Over";
    }
    {
      key = "<leader>dO";
      mode = "n";
      action.__raw = "function() require('dap').step_out() end";
      options.desc = "DAP: Step Out";
    }
    {
      key = "<leader>du";
      mode = "n";
      action.__raw = "function() require('dapui').toggle() end";
      options.desc = "DAP: Toggle UI";
    }
  ];
}
