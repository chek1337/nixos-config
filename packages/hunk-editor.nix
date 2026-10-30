{ inputs, ... }:
{
  # $EDITOR-обёртка для hunk, чтобы открытие файла не поднимало LSP с нуля
  # (подробности в ./hunk-editor.sh). Нужна двум сторонам: zsh-алиасу `hunk`
  # (modules/programs/cli-tools/hunk.nix) и терминалу <leader>gdh внутри nvim
  # (nixvim/plugins/git/hunk.nix, прокидывается как module arg hunkEditorPkg).
  #
  # Скрипт лежит в $out/libexec/hunk-editor/nvim, а не в bin: basename обязан
  # быть `nvim` (иначе hunk не передаст номер строки), и при этом он не должен
  # затенять настоящий nvim в PATH.
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      packages.hunk-editor = pkgs.writeTextFile {
        name = "hunk-editor";
        destination = "/libexec/hunk-editor/nvim";
        executable = true;
        text = ''
          #!${pkgs.runtimeShell}
          export PATH=${
            pkgs.lib.makeBinPath [
              pkgs.coreutils
              pkgs.git
              pkgs.util-linux
            ]
          }:$PATH
        ''
        + builtins.readFile ./hunk-editor.sh;
      };
    };
}
