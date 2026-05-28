{ ... }:
{
  plugins.dap-virtual-text = {
    enable = true;
    lazyLoad.settings = {
      event = "DeferredUIEnter";
      # nvim-dap-virtual-text.lua на верхнем уровне делает require("dap"),
      # поэтому dap должен быть на rtp до нашего packadd.
      before.__raw = "function() require('lz.n').trigger_load('nvim-dap') end";
    };

    settings.display_callback.__raw = ''
      function(variable, buf, stackframe, node, options)
        local val = variable.value:gsub("%s+", " ")
        if #val > 40 then val = val:sub(1, 20) .. "…" .. val:sub(-20) end
        if options.virt_text_pos == "inline" then
          return " = " .. val
        else
          return variable.name .. " = " .. val
        end
      end
    '';
  };
}
