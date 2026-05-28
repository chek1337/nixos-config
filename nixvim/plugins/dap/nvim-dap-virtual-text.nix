{ ... }:
{
  plugins.dap-virtual-text = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";

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
