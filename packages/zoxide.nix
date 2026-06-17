{ inputs, ... }:
{
  # Standalone-пакет zoxide для не-NixOS машин (Ubuntu и т.п.):
  #   nix profile install github:chek1337/nixos-config#zoxide
  #
  # В отличие от tmux/nvim у zoxide нет конфиг-файла — вся настройка это
  # shell-интеграция (`eval "$(zoxide init zsh)"`) плюс мой алиас `cd = z`,
  # см. modules/programs/cli-tools/zoxide.nix. `nix profile install` бинаря не
  # может сам дописать строку в чужой ~/.zshrc, поэтому пакет дополнительно
  # кладёт готовый sourceable init: $out/share/zoxide/init.zsh. На целевой
  # машине достаточно одной строки в ~/.zshrc:
  #
  #   source ~/.nix-profile/share/zoxide/init.zsh
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
      zoxide = pkgs.zoxide;

      # Статический zsh-init: интеграция zoxide (z / zi) + мой `cd = z`.
      # Сгенерированные хуки зовут `command zoxide`, поэтому страхуемся и кладём
      # бинарь из этого же пакета на PATH — init самодостаточен даже до того, как
      # профиль попадёт в PATH.
      initZsh = pkgs.runCommand "zoxide-init.zsh" { } ''
        {
          echo '# zoxide standalone init — source this from ~/.zshrc'
          echo 'export PATH="${zoxide}/bin:$PATH"'
          ${zoxide}/bin/zoxide init zsh
          echo 'alias cd=z'
        } > "$out"
      '';

      pkg = pkgs.symlinkJoin {
        name = "zoxide-standalone";
        paths = [ zoxide ];
        postBuild = ''
          install -Dm644 ${initZsh} "$out/share/zoxide/init.zsh"
        '';
      };
    in
    {
      packages.zoxide = pkg;
      apps.zoxide = {
        type = "app";
        program = "${pkg}/bin/zoxide";
      };
    };
}
