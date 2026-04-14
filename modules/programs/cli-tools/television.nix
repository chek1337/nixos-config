{ ... }:
{
  flake.modules.homeManager.television =
    { pkgs, ... }:
    {
      programs.television = {
        enable = true;
        enableZshIntegration = true;

        settings = { };

        channels = {
          sesh = {
            metadata = {
              name = "sesh";
              description = "Session manager integrating tmux sessions, zoxide directories, and config paths";
              requirements = [
                "sesh"
                "fd"
              ];
            };
            source = {
              command = [
                "sesh list -t --icons"
                "sesh list --icons"
              ];
              ansi = true;
              output = "{strip_ansi|split: :1..|join: }";
            };
            preview = {
              command = ''
                bash -c '
                  p=$(eval echo "{strip_ansi|split: :1..|join: }")
                  if [ -d "$p" ]; then
                    eza --tree --icons --color=always --level=2 "$p"
                  else
                    sesh preview "$p"
                  fi
                '
              '';
            };
            keybindings = {
              enter = "actions:connect";
              "ctrl-d" = [
                "actions:kill_session"
                "reload_source"
              ];
            };
            actions = {
              connect = {
                description = "Connect to selected session";
                command = "sesh connect '{strip_ansi|split: :1..|join: }'";
                mode = "execute";
              };
              kill_session = {
                description = "Kill selected tmux session";
                command = "tmux kill-session -t '{strip_ansi|split: :1..|join: }'";
                mode = "fork";
              };
            };
          };
        };
      };

      # programs.zsh.initContent = ''
      #   bindkey -s '^S' 'tv --ui-scale 80 sesh\n'
      # '';

      home.packages = [ pkgs.fd ];
    };
}
