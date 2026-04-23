# Shell option: zsh
# Select in hosts/*/host.nix via: shell = "zsh"
{
  flake.modules.nixos.zsh =
    { pkgs, config, ... }:
    let
      username = config.settings.username;
    in
    {
      programs.zsh.enable = true;
      users.users.${username}.shell = pkgs.zsh;
    };

  flake.modules.homeManager.zsh =
    { pkgs, lib, ... }:
    {
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" ];
        };
        initContent = lib.mkMerge [
          ''
          WORDCHARS='*?_[]~=&;!#$%^(){}'
          bindkey " " magic-space

          # z4h-style word deletion: удаляет по одной группе символов за раз
          # (буквы/цифры, спецсимволы, пробелы — каждая группа отдельно)
          # https://github.com/romkatv/zsh4humans/blob/v5/fn/-z4h-init-zle#L75-L78
          z4h-backward-kill-word() {
            emulate -L zsh
            local -i end=$CURSOR pos=$CURSOR
            (( pos == 0 )) && return
            # пропустить пробелы
            while (( pos > 0 )) && [[ $BUFFER[pos] == [[:space:]] ]]; do
              (( pos-- ))
            done
            if (( pos > 0 )); then
              if [[ $BUFFER[pos] == [[:alnum:]] ]]; then
                while (( pos > 0 )) && [[ $BUFFER[pos] == [[:alnum:]] ]]; do
                  (( pos-- ))
                done
              else
                while (( pos > 0 )) && [[ $BUFFER[pos] != [[:alnum:][:space:]] ]]; do
                  (( pos-- ))
                done
              fi
            fi
            CUTBUFFER=$BUFFER[pos+1,end]
            BUFFER=$BUFFER[1,pos]$BUFFER[end+1,-1]
            CURSOR=$pos
          }
          zle -N z4h-backward-kill-word

          z4h-kill-word() {
            emulate -L zsh
            local -i start=$((CURSOR + 1)) pos=$((CURSOR + 1)) len=$#BUFFER
            (( start > len )) && return
            while (( pos <= len )) && [[ $BUFFER[pos] == [[:space:]] ]]; do
              (( pos++ ))
            done
            if (( pos <= len )); then
              if [[ $BUFFER[pos] == [[:alnum:]] ]]; then
                while (( pos <= len )) && [[ $BUFFER[pos] == [[:alnum:]] ]]; do
                  (( pos++ ))
                done
              else
                while (( pos <= len )) && [[ $BUFFER[pos] != [[:alnum:][:space:]] ]]; do
                  (( pos++ ))
                done
              fi
            fi
            CUTBUFFER=$BUFFER[start,pos-1]
            BUFFER=$BUFFER[1,start-1]$BUFFER[pos,-1]
          }
          zle -N z4h-kill-word

          # удаляет целый аргумент (весь путь, URL и т.д.)
          z4h-backward-kill-zword() {
            local WORDCHARS='*?_[]~=&;!#$%^(){}<>/.:-'
            zle backward-kill-word
          }
          zle -N z4h-backward-kill-zword

          # Ctrl+Backspace / Ctrl+W → гранулярное удаление назад
          bindkey '^W' z4h-backward-kill-word
          bindkey '^H' z4h-backward-kill-word
          # Ctrl+Delete → гранулярное удаление вперёд
          bindkey '^[[3;5~' z4h-kill-word
          # Alt+Backspace → удалить целый аргумент
          bindkey '^[^?' z4h-backward-kill-zword

          source ${pkgs.fzf}/share/fzf/key-bindings.zsh
          source ${pkgs.fzf}/share/fzf/completion.zsh
          ''
          (lib.mkAfter ''
            # OSC 133 semantic prompt markers — для tmux-copy-last-command (prefix+y / prefix+Y).
            # C эмитится из preexec; A встроен в PROMPT через %{...%}, потому что ZLE \r\e[K
            # перед каждой перерисовкой после первой сбрасывает GRID_LINE_START_PROMPT.
            # Re-apply на precmd нужен для тем, пересобирающих PROMPT (starship — как раз такой).
            #
            # Leading newlines (starship.add_newline=true) сдвигают A на пустую row ВЫШЕ
            # реального prompt'а → previous-prompt прыгает не туда, prefix+y ломается.
            # Фикс: перемещаем маркер ЗА все leading \n, чтобы он лёг на row с prompt'ом.
            autoload -Uz add-zsh-hook
            _osc133_preexec() { printf '\e]133;C\a' }
            _osc133_decorate_prompt() {
              [[ "$PS1" == *$'\e]133;A'* ]] && return
              local nl=""
              while [[ "$PS1" == $'\n'* ]]; do
                nl+=$'\n'
                PS1="''${PS1#$'\n'}"
              done
              PS1="$nl%{"$'\e]133;A\a'"%}$PS1"
            }
            add-zsh-hook preexec _osc133_preexec
            add-zsh-hook precmd  _osc133_decorate_prompt
          '')
        ];
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          directory = {
            truncation_length = 0;
            truncate_to_repo = false;
          };
        };
      };
    };
}
