{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    nvim-dap-virtual-text = {
      package = nvim-dap-virtual-text;
      setup = # lua
        ''
          require("nvim-dap-virtual-text").setup({
            display_callback = function(variable, buf, stackframe, node, options)
              local val = variable.value:gsub("%s+", " ")
              if #val > 40 then val = val:sub(1, 20) .. "…" .. val:sub(-20) end
              if options.virt_text_pos == "inline" then
                return " = " .. val
              else
                return variable.name .. " = " .. val
              end
            end,
          })
        '';
      after = [ "nvim-dap" ];
    };
  };
}
