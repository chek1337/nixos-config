{ lib, ... }:
{
  vim.git = {
    enable = true;

    gitsigns = {
      enable = true;

      setupOpts = {
        signs = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
          untracked.text = "▎";
        };
        signs_staged = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
        };
        on_attach =
          lib.mkLuaInline # lua
            ''
              function(buffer)
                vim.keymap.set("n", "<leader>ghp",
                  package.loaded.gitsigns.preview_hunk_inline,
                  { buffer = buffer, desc = "Preview Hunk Inline [Gitsigns]", silent = true })
              end
            '';
      };
    };
  };
}
