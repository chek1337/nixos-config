{ ... }:
{
  plugins.lint = {
    enable = true;
    lintersByFt = { };
  };

  extraConfigLua = ''
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("nvim_lint_autotrigger", { clear = true }),
      callback = function()
        require("lint").try_lint()
      end,
    })
  '';
}
