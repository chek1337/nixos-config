{ ... }:
{
  flake.modules.homeManager.television =
    { pkgs, ... }:
    {
      programs.television = {
        enable = true;
        package = pkgs.television;
        enableZshIntegration = false;

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
            # NOTE: no `enter = "actions:connect"` on purpose. television 0.15.6
            # runs `mode = "execute"` actions without inheriting the TTY fds, so
            # `sesh connect` -> `tmux attach/switch-client` fails with
            # "exit status 1" (upstream alexpasmantier/television#1052, sesh #368).
            # Instead Enter just prints the selection to stdout and the caller
            # (sesh-tv wrapper) runs `sesh connect`.
            keybindings = {
              "ctrl-d" = [
                "actions:kill_session"
                "reload_source"
              ];
            };
            actions = {
              kill_session = {
                description = "Kill selected tmux session";
                command = "tmux kill-session -t '{strip_ansi|split: :1..|join: }'";
                mode = "fork";
              };
            };
          };

          text = {
            metadata = {
              name = "text";
              description = "Search file contents (no filename matching)";
            };
            source = {
              command = [
                "rg . --no-heading --line-number --color=never"
                "rg . --no-heading --line-number --hidden --color=never"
              ];
              display = "{split:\\::2..}";
              output = "{}";
            };
            preview = {
              command = "bat -n --color=always --highlight-line '{split:\\::1}' '{split:\\::0}'";
              offset = "{split:\\::1}";
            };
            ui = {
              preview_panel = {
                header = "{split:\\::..2}";
              };
            };
          };

          env = {
            metadata = {
              name = "env";
              description = "A channel to select from environment variables";
            };
            source = {
              command = "printenv";
              output = "{split:=:1..}";
            };
            preview.command = "echo '{split:=:1..}'";
            ui = {
              layout = "portrait";
              preview_panel = {
                size = 20;
                header = "{split:=:0}";
              };
            };
            keybindings.shortcut = "f3";
            actions.name = {
              description = "Output the variable name instead of the value";
              command = "echo '{split:=:0}'";
              mode = "execute";
            };
          };

          path = {
            metadata = {
              name = "path";
              description = "Investigate PATH contents";
              requirements = [
                "fd"
                "bat"
              ];
            };
            source.command = "printf '%s\\n' \"$PATH\" | tr ':' '\\n'";
            preview.command = "fd -tx -d1 . \"{}\" -X printf \"%s\\n\" \"{/}\" | sort -f | bat -n --color=always";
            actions.cd = {
              description = "Open a shell in the selected PATH directory";
              command = "cd '{}' && $SHELL";
              mode = "execute";
            };
          };

          "systemd-units" = {
            metadata = {
              name = "systemd-units";
              description = "List and manage systemd services";
              requirements = [ "systemctl" ];
            };
            source = {
              command = [
                "systemctl list-units --type=service --no-pager --no-legend --plain"
                "systemctl list-units --type=service --all --no-pager --no-legend --plain"
              ];
              display = "{split: :0}";
            };
            preview.command = "systemctl status '{split: :0}' --no-pager";
            ui.layout = "portrait";
            keybindings = {
              "ctrl-s" = "actions:start";
              "f2" = "actions:stop";
              "ctrl-r" = "actions:restart";
              "ctrl-e" = "actions:enable";
              "ctrl-d" = "actions:disable";
            };
            actions = {
              start = {
                description = "Start the selected service";
                command = "sudo systemctl start '{split: :0}'";
                mode = "execute";
              };
              stop = {
                description = "Stop the selected service";
                command = "sudo systemctl stop '{split: :0}'";
                mode = "execute";
              };
              restart = {
                description = "Restart the selected service";
                command = "sudo systemctl restart '{split: :0}'";
                mode = "execute";
              };
              enable = {
                description = "Enable the selected service";
                command = "sudo systemctl enable '{split: :0}'";
                mode = "execute";
              };
              disable = {
                description = "Disable the selected service";
                command = "sudo systemctl disable '{split: :0}'";
                mode = "execute";
              };
            };
          };

          journal = {
            metadata = {
              name = "journal";
              description = "Browse systemd journal log identifiers and their logs";
              requirements = [ "journalctl" ];
            };
            source.command = "journalctl --field SYSLOG_IDENTIFIER 2>/dev/null | sort -f";
            preview.command = "journalctl -b --no-pager -o short-iso -n 50 SYSLOG_IDENTIFIER='{}' 2>/dev/null";
            ui = {
              layout = "portrait";
              preview_panel.size = 70;
            };
            actions = {
              logs = {
                description = "Follow live logs for the selected identifier";
                command = "journalctl -f SYSLOG_IDENTIFIER='{}'";
                mode = "execute";
              };
              full = {
                description = "View all logs for the selected identifier in a pager";
                command = "journalctl -b --no-pager -o short-iso SYSLOG_IDENTIFIER='{}' | less";
                mode = "fork";
              };
            };
          };

          "docker-containers" = {
            metadata = {
              name = "docker-containers";
              description = "List and manage Docker containers";
              requirements = [
                "docker"
                "jq"
              ];
            };
            source = {
              command = [
                "docker ps --format '{{.Names}}\\t{{.Image}}\\t{{.Status}}'"
                "docker ps -a --format '{{.Names}}\\t{{.Image}}\\t{{.Status}}'"
              ];
              display = "{split:\\t:0} ({split:\\t:2})";
              output = "{split:\\t:0}";
            };
            preview.command = "docker inspect '{split:\\t:0}' | jq -C '.[0] | {Name, State, Config: {Image: .Config.Image, Cmd: .Config.Cmd}, NetworkSettings: {IPAddress: .NetworkSettings.IPAddress}}'";
            ui.layout = "portrait";
            keybindings = {
              "ctrl-s" = "actions:start";
              "f2" = "actions:stop";
              "ctrl-r" = "actions:restart";
              "ctrl-l" = "actions:logs";
              "ctrl-e" = "actions:exec";
              "ctrl-d" = "actions:remove";
            };
            actions = {
              start = {
                description = "Start the selected container";
                command = "docker start '{split:\\t:0}'";
                mode = "fork";
              };
              stop = {
                description = "Stop the selected container";
                command = "docker stop '{split:\\t:0}'";
                mode = "fork";
              };
              restart = {
                description = "Restart the selected container";
                command = "docker restart '{split:\\t:0}'";
                mode = "fork";
              };
              logs = {
                description = "Follow logs of the selected container";
                command = "docker logs -f '{split:\\t:0}'";
                mode = "execute";
              };
              exec = {
                description = "Execute shell in the selected container";
                command = "docker exec -it '{split:\\t:0}' /bin/sh";
                mode = "execute";
              };
              remove = {
                description = "Remove the selected container";
                command = "docker rm '{split:\\t:0}'";
                mode = "execute";
              };
            };
          };

          "docker-images" = {
            metadata = {
              name = "docker-images";
              description = "A channel to select from Docker images";
              requirements = [
                "docker"
                "jq"
              ];
            };
            source = {
              command = "docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}'";
              output = "{split: :-1}";
            };
            preview.command = "docker image inspect '{split: :-1}' | jq -C";
            ui.layout = "portrait";
            keybindings = {
              "ctrl-r" = "actions:run";
              "ctrl-d" = "actions:remove";
              "ctrl-s" = "actions:shell";
            };
            actions = {
              run = {
                description = "Run a container from the selected image";
                command = "docker run -it '{split: :-1}'";
                mode = "execute";
              };
              shell = {
                description = "Run a shell in the selected image";
                command = "docker run -it '{split: :-1}' /bin/sh";
                mode = "execute";
              };
              remove = {
                description = "Remove the selected image";
                command = "docker rmi '{split: :-1}'";
                mode = "execute";
              };
            };
          };

          "docker-compose" = {
            metadata = {
              name = "docker-compose";
              description = "Manage Docker Compose services";
              requirements = [ "docker" ];
            };
            source = {
              command = "docker compose ps --format '{{.Name}}\t{{.Service}}\t{{.Status}}'";
              display = "{split:\t:1} ({split:\t:2})";
              output = "{split:\t:1}";
            };
            preview.command = "docker compose logs --tail=30 --no-log-prefix '{split:\t:1}'";
            actions = {
              up = {
                description = "Start the selected service";
                command = "docker compose up -d '{split:\t:1}'";
                mode = "fork";
              };
              down = {
                description = "Stop and remove the selected service";
                command = "docker compose down '{split:\t:1}'";
                mode = "fork";
              };
              restart = {
                description = "Restart the selected service";
                command = "docker compose restart '{split:\t:1}'";
                mode = "fork";
              };
              logs = {
                description = "Follow logs of the selected service";
                command = "docker compose logs -f '{split:\t:1}'";
                mode = "execute";
              };
            };
          };

          "docker-networks" = {
            metadata = {
              name = "docker-networks";
              description = "List and manage Docker networks";
              requirements = [
                "docker"
                "jq"
              ];
            };
            source = {
              command = "docker network ls --format '{{.Name}}\t{{.Driver}}\t{{.Scope}}'";
              display = "{split:\t:0} ({split:\t:1}, {split:\t:2})";
              output = "{split:\t:0}";
            };
            preview.command = "docker network inspect '{split:\t:0}' | jq -C '.[0] | {Name, Driver, Scope, IPAM, Containers: (.Containers // {} | to_entries | map({name: .value.Name, ipv4: .value.IPv4Address}))}'";
            ui.layout = "portrait";
            actions.remove = {
              description = "Remove the selected network";
              command = "docker network rm '{split:\t:0}'";
              mode = "execute";
            };
          };

          "docker-volumes" = {
            metadata = {
              name = "docker-volumes";
              description = "List and manage Docker volumes";
              requirements = [
                "docker"
                "jq"
              ];
            };
            source = {
              command = "docker volume ls --format '{{.Name}}\t{{.Driver}}'";
              display = "{split:\t:0} ({split:\t:1})";
              output = "{split:\t:0}";
            };
            preview.command = "docker volume inspect '{split:\t:0}' | jq -C '.[0]'";
            ui.layout = "portrait";
            actions = {
              remove = {
                description = "Remove the selected volume";
                command = "docker volume rm '{split:\t:0}'";
                mode = "execute";
              };
              inspect = {
                description = "Inspect the selected volume in a pager";
                command = "docker volume inspect '{split:\t:0}' | jq -C '.[0]' | less -R";
                mode = "execute";
              };
            };
          };

          "podman-containers" = {
            metadata = {
              name = "podman-containers";
              description = "List and manage Podman containers";
              requirements = [
                "podman"
                "jq"
              ];
            };
            source = {
              command = [
                "podman ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}'"
                "podman ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}'"
              ];
              display = "{split:\t:0} ({split:\t:2})";
              output = "{split:\t:0}";
            };
            preview.command = "podman inspect '{split:\t:0}' | jq -C '.[0] | {Name, State, Config: {Image: .Config.Image, Cmd: .Config.Cmd}, NetworkSettings: {IPAddress: .NetworkSettings.IPAddress}}'";
            ui.layout = "portrait";
            keybindings = {
              "ctrl-s" = "actions:start";
              "f2" = "actions:stop";
              "ctrl-r" = "actions:restart";
              "ctrl-l" = "actions:logs";
              "ctrl-e" = "actions:exec";
              "ctrl-d" = "actions:remove";
            };
            actions = {
              start = {
                description = "Start the selected container";
                command = "podman start '{split:\t:0}'";
                mode = "fork";
              };
              stop = {
                description = "Stop the selected container";
                command = "podman stop '{split:\t:0}'";
                mode = "fork";
              };
              restart = {
                description = "Restart the selected container";
                command = "podman restart '{split:\t:0}'";
                mode = "fork";
              };
              logs = {
                description = "Follow logs of the selected container";
                command = "podman logs -f '{split:\t:0}'";
                mode = "execute";
              };
              exec = {
                description = "Execute shell in the selected container";
                command = "podman exec -it '{split:\t:0}' /bin/sh";
                mode = "execute";
              };
              remove = {
                description = "Remove the selected container";
                command = "podman rm '{split:\t:0}'";
                mode = "execute";
              };
            };
          };

          "podman-images" = {
            metadata = {
              name = "podman-images";
              description = "A channel to select from Podman images";
              requirements = [
                "podman"
                "jq"
              ];
            };
            source = {
              command = "podman images --format '{{.Repository}}:{{.Tag}} {{.ID}}'";
              output = "{split: :-1}";
            };
            preview.command = "podman image inspect '{split: :-1}' | jq -C";
            ui.layout = "portrait";
            keybindings = {
              "ctrl-r" = "actions:run";
              "ctrl-d" = "actions:remove";
              "ctrl-s" = "actions:shell";
            };
            actions = {
              run = {
                description = "Run a container from the selected image";
                command = "podman run -it '{split: :-1}'";
                mode = "execute";
              };
              shell = {
                description = "Run a shell in the selected image";
                command = "podman run -it '{split: :-1}' /bin/sh";
                mode = "execute";
              };
              remove = {
                description = "Remove the selected image";
                command = "podman rmi '{split: :-1}'";
                mode = "execute";
              };
            };
          };

          "podman-networks" = {
            metadata = {
              name = "podman-networks";
              description = "List and manage Podman networks";
              requirements = [
                "podman"
                "jq"
              ];
            };
            source = {
              command = "podman network ls --format '{{.Name}}\t{{.Driver}}\t{{.Internal}}'";
              display = "{split:\t:0} ({split:\t:1})";
              output = "{split:\t:0}";
            };
            preview.command = "podman network inspect '{split:\t:0}' | jq -C '.[0] | {name, driver, subnets, dns_enabled, internal}'";
            ui.layout = "portrait";
            actions.remove = {
              description = "Remove the selected network";
              command = "podman network rm '{split:\t:0}'";
              mode = "execute";
            };
          };

          "podman-volumes" = {
            metadata = {
              name = "podman-volumes";
              description = "List and manage Podman volumes";
              requirements = [
                "podman"
                "jq"
              ];
            };
            source = {
              command = "podman volume ls --format '{{.Name}}\t{{.Driver}}'";
              display = "{split:\t:0} ({split:\t:1})";
              output = "{split:\t:0}";
            };
            preview.command = "podman volume inspect '{split:\t:0}' | jq -C '.[0]'";
            ui.layout = "portrait";
            actions = {
              remove = {
                description = "Remove the selected volume";
                command = "podman volume rm '{split:\t:0}'";
                mode = "execute";
              };
              inspect = {
                description = "Inspect the selected volume in a pager";
                command = "podman volume inspect '{split:\t:0}' | jq -C '.[0]' | less -R";
                mode = "execute";
              };
            };
          };

          "git-branch" = {
            metadata = {
              name = "git-branch";
              description = "A channel to select from git branches";
              requirements = [ "git" ];
            };
            source = {
              command = "git --no-pager branch --all --format=\"%(refname:short)\"";
              output = "{split: :0}";
            };
            preview.command = "git show -p --stat --pretty=fuller --color=always '{0}'";
            keybindings = {
              enter = "actions:checkout";
              "ctrl-d" = "actions:delete";
              "ctrl-m" = "actions:merge";
              "ctrl-r" = "actions:rebase";
            };
            actions = {
              checkout = {
                description = "Checkout the selected branch";
                command = "git checkout '{0}'";
                mode = "execute";
              };
              delete = {
                description = "Delete the selected branch";
                command = "git branch -d '{0}'";
                mode = "execute";
              };
              merge = {
                description = "Merge the selected branch into current branch";
                command = "git merge '{0}'";
                mode = "execute";
              };
              rebase = {
                description = "Rebase current branch onto the selected branch";
                command = "git rebase '{0}'";
                mode = "execute";
              };
            };
          };

          "git-log" = {
            metadata = {
              name = "git-log";
              description = "A channel to select from git log entries";
              requirements = [ "git" ];
            };
            source = {
              command = "git log --graph --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color=always";
              output = "{strip_ansi|split: :1}";
              ansi = true;
              no_sort = true;
              frecency = false;
            };
            preview.command = "git show -p --stat --pretty=fuller --color=always '{strip_ansi|split: :1}' | head -n 1000";
            keybindings = {
              "ctrl-y" = "actions:cherry-pick";
              "ctrl-r" = "actions:revert";
              "ctrl-o" = "actions:checkout";
            };
            actions = {
              "cherry-pick" = {
                description = "Cherry-pick the selected commit";
                command = "git cherry-pick '{strip_ansi|split: :1}'";
                mode = "execute";
              };
              revert = {
                description = "Revert the selected commit";
                command = "git revert '{strip_ansi|split: :1}'";
                mode = "execute";
              };
              checkout = {
                description = "Checkout the selected commit";
                command = "git checkout '{strip_ansi|split: :1}'";
                mode = "execute";
              };
            };
          };

          "git-diff" = {
            metadata = {
              name = "git-diff";
              description = "A channel to select files from git diff commands";
              requirements = [ "git" ];
            };
            source.command = "git diff --name-only HEAD";
            preview.command = "git diff HEAD --color=always -- '{}'";
            ui.layout = "portrait";
            keybindings = {
              "ctrl-s" = "actions:stage";
              "ctrl-r" = "actions:restore";
              "ctrl-e" = "actions:edit";
            };
            actions = {
              stage = {
                description = "Stage the selected file";
                command = "git add '{}'";
                mode = "fork";
              };
              restore = {
                description = "Discard changes in the selected file";
                command = "git restore '{}'";
                mode = "fork";
              };
              edit = {
                description = "Open the selected file in editor";
                command = "\${EDITOR:-vim} '{}'";
                shell = "bash";
                mode = "execute";
              };
            };
          };

          "git-files" = {
            metadata = {
              name = "git-files";
              description = "A channel to list the files currently tracked in the Git repository";
              requirements = [
                "git"
                "bat"
              ];
            };
            source.command = "git ls-files $(git rev-parse --show-toplevel)";
            preview = {
              command = "bat -n --color=always '{}'";
              env.BAT_THEME = "ansi";
            };
            keybindings."f12" = "actions:edit";
            actions.edit = {
              description = "Opens the selected entries with the default editor (falls back to vim)";
              command = "\${EDITOR:-vim} '{}'";
              shell = "bash";
              mode = "execute";
            };
          };

          "git-stash" = {
            metadata = {
              name = "git-stash";
              description = "Browse and manage git stash entries";
              requirements = [ "git" ];
            };
            source = {
              command = "git stash list --color=always";
              ansi = true;
              output = "{strip_ansi|split:\\::0}";
              no_sort = true;
              frecency = false;
            };
            preview.command = "git stash show -p --color=always '{strip_ansi|split:\\::0}'";
            ui.layout = "portrait";
            keybindings = {
              enter = "actions:apply";
              "ctrl-p" = "actions:pop";
              "ctrl-d" = "actions:drop";
            };
            actions = {
              apply = {
                description = "Apply the selected stash";
                command = "git stash apply '{strip_ansi|split:\\::0}'";
                mode = "execute";
              };
              pop = {
                description = "Pop the selected stash (apply and remove)";
                command = "git stash pop '{strip_ansi|split:\\::0}'";
                mode = "execute";
              };
              drop = {
                description = "Drop the selected stash";
                command = "git stash drop '{strip_ansi|split:\\::0}'";
                mode = "execute";
              };
            };
          };

          "git-reflog" = {
            metadata = {
              name = "git-reflog";
              description = "A channel to select from git reflog entries";
              requirements = [ "git" ];
            };
            source = {
              command = "git reflog --decorate --color=always";
              output = "{0|strip_ansi}";
              ansi = true;
              no_sort = true;
              frecency = false;
            };
            preview.command = "git show -p --stat --pretty=fuller --color=always '{0|strip_ansi}'";
            keybindings = {
              "ctrl-o" = "actions:checkout";
              "ctrl-r" = "actions:reset";
            };
            actions = {
              checkout = {
                description = "Checkout the selected reflog entry";
                command = "git checkout '{0|strip_ansi}'";
                mode = "execute";
              };
              reset = {
                description = "Reset --hard to the selected reflog entry";
                command = "git reset --hard '{0|strip_ansi}'";
                mode = "execute";
              };
            };
          };

          "git-tags" = {
            metadata = {
              name = "git-tags";
              description = "Browse and checkout git tags";
              requirements = [ "git" ];
            };
            source = {
              command = "git tag --sort=-creatordate";
              no_sort = true;
              frecency = false;
            };
            preview.command = "git show --color=always '{}'";
            keybindings = {
              enter = "actions:checkout";
              "ctrl-d" = "actions:delete";
            };
            actions = {
              checkout = {
                description = "Checkout the selected tag";
                command = "git checkout '{}'";
                mode = "execute";
              };
              delete = {
                description = "Delete the selected tag";
                command = "git tag -d '{}'";
                mode = "execute";
              };
            };
          };

          "git-remotes" = {
            metadata = {
              name = "git-remotes";
              description = "List and manage git remotes";
              requirements = [ "git" ];
            };
            source.command = "git remote";
            preview.command = "git remote show '{}'";
            actions = {
              fetch = {
                description = "Fetch from the selected remote";
                command = "git fetch '{}'";
                mode = "execute";
              };
              remove = {
                description = "Remove the selected remote";
                command = "git remote remove '{}'";
                mode = "execute";
              };
            };
          };

          "git-repos" = {
            metadata = {
              name = "git-repos";
              description = "A channel to select from git repositories on your local machine.";
              requirements = [
                "fd"
                "git"
              ];
            };
            source = {
              command = "fd -g .git -HL -t d -d 10 --prune ~ -E 'Library' -E 'Application Support' --exec dirname '{}'";
              display = "{split:/:-1}";
            };
            preview.command = "cd '{}'; git log -n 200 --pretty=medium --all --graph --color";
            keybindings = {
              enter = "actions:cd";
              "ctrl-e" = "actions:edit";
            };
            actions = {
              cd = {
                description = "Open a new shell in the selected repository";
                command = "cd '{}' && $SHELL";
                mode = "execute";
              };
              edit = {
                description = "Open the repository in editor";
                command = "\${EDITOR:-vim} '{}'";
                shell = "bash";
                mode = "execute";
              };
            };
          };

          "git-worktrees" = {
            metadata = {
              name = "git-worktrees";
              description = "List and switch between git worktrees";
              requirements = [ "git" ];
            };
            source.command = "git worktree list --porcelain | grep '^worktree' | cut -d' ' -f2-";
            preview.command = "cd '{}' && git log --oneline -10 --color=always && echo && git status --short";
            keybindings = {
              enter = "actions:cd";
              "ctrl-d" = "actions:remove";
            };
            actions = {
              cd = {
                description = "Change to the selected worktree";
                command = "cd '{}' && $SHELL";
                mode = "execute";
              };
              remove = {
                description = "Remove the selected worktree";
                command = "git worktree remove '{}'";
                mode = "execute";
              };
            };
          };

          "git-deletions" = {
            metadata = {
              name = "git-deletions";
              description = "A channel to list files which were deleted from the Git repository";
              requirements = [
                "git"
                "rg"
                "bat"
              ];
            };
            source.command = "git log --diff-filter=D --summary | rg 'delete mode \\d+' -r '' --trim";
            preview.command = [
              "git show \"$(git rev-list -n1 HEAD -- '{}')^:{}\" | bat -n --color always --file-name '{}'"
              "git show --summary \"$(git rev-list -n1 HEAD -- '{}')\""
            ];
            keybindings = {
              enter = "actions:print_commit";
              "ctrl-r" = "actions:restore_file";
            };
            actions = {
              print_commit = {
                description = "Print the latest commit where file was deleted";
                command = "echo \"$(git rev-list -n1 HEAD -- '{}')\"";
                mode = "execute";
              };
              restore_file = {
                description = "Restore the selected file";
                command = "git checkout \"$(git rev-list -n1 HEAD -- '{}')^\" -- '{}'";
                mode = "execute";
              };
            };
          };

          alias = {
            metadata = {
              name = "alias";
              description = "A channel to select from shell aliases";
            };
            source = {
              command = "zsh -c 'source ~/.zshrc 2>/dev/null; alias' 2>/dev/null";
              output = "{split:=:0}";
            };
            preview.command = "zsh -c 'source ~/.zshrc 2>/dev/null; alias' 2>/dev/null | grep -E '^(alias )?{split:=:0}='";
            ui.preview_panel.size = 30;
          };

          "distrobox-list" = {
            metadata = {
              name = "distrobox-list";
              description = "A channel to select a container from distrobox";
              requirements = [
                "distrobox"
                "bat"
              ];
            };
            source = {
              command = [ "distrobox list | awk -F '|' '{ gsub(/ /, \"\", $2); print $2}' | tail --lines=+2" ];
              shell = "bash";
            };
            preview = {
              command = "(distrobox list | column -t -s '|' | awk -v selected_name={} 'NR==1 || $0 ~ selected_name') && echo && distrobox enter -d {} | bat --plain --color=always -lbash";
              shell = "bash";
            };
            keybindings = {
              "ctrl-e" = "actions:distrobox-enter";
              "ctrl-l" = "actions:distrobox-list";
              "ctrl-r" = "actions:distrobox-rm";
              "ctrl-s" = "actions:distrobox-stop";
              "ctrl-u" = "actions:distrobox-upgrade";
            };
            actions = {
              "distrobox-enter" = {
                description = "Enter a distrobox";
                command = "distrobox enter {}";
                mode = "execute";
              };
              "distrobox-list" = {
                description = "List a distrobox";
                command = "distrobox list | column -t -s '|' | awk -v selected_name={} 'NR==1 || $0 ~ selected_name'";
                mode = "execute";
              };
              "distrobox-rm" = {
                description = "Remove a distrobox";
                command = "distrobox rm {}";
                mode = "execute";
              };
              "distrobox-stop" = {
                description = "Stop a distrobox";
                command = "distrobox stop {}";
                mode = "execute";
              };
              "distrobox-upgrade" = {
                description = "Upgrade a distrobox";
                command = "distrobox upgrade {}";
                mode = "execute";
              };
            };
          };

          "git-submodules" = {
            metadata = {
              name = "git-submodules";
              description = "List and manage git submodules";
              requirements = [ "git" ];
            };
            source.command = "git submodule status | awk '{print $2}'";
            preview.command = "git -C '{}' log --oneline -10 --color=always";
            actions = {
              update = {
                description = "Update the selected submodule";
                command = "git submodule update --init --recursive '{}'";
                mode = "execute";
              };
              sync = {
                description = "Sync the selected submodule URL";
                command = "git submodule sync '{}'";
                mode = "execute";
              };
            };
          };

          "man-pages" = {
            metadata = {
              name = "man-pages";
              description = "Browse and preview system manual pages";
              requirements = [
                "apropos"
                "man"
              ];
            };
            source.command = "apropos .";
            preview = {
              command = "man '{0}'";
              env.MANWIDTH = "80";
            };
            keybindings.enter = "actions:open";
            actions.open = {
              description = "Open the selected man page in the system pager";
              command = "man '{0}'";
              mode = "execute";
            };
            ui = {
              layout = "portrait";
              preview_panel.header = "{0}";
            };
          };

          mounts = {
            metadata = {
              name = "mounts";
              description = "List mounted filesystems";
              requirements = [
                "df"
                "awk"
              ];
            };
            source = {
              command = "df -h --output=target,fstype,size,used,avail,pcent 2>/dev/null | tail -n +2";
              display = "{split: :0}";
            };
            preview.command = "df -h '{}' && echo && ls -la '{}' 2>/dev/null | head -20";
            keybindings.enter = "actions:cd";
            actions.cd = {
              description = "Open a shell in the selected mount point";
              command = "cd '{}' && $SHELL";
              mode = "execute";
            };
          };

          ports = {
            metadata = {
              name = "ports";
              description = "List listening ports and associated processes";
              requirements = [
                "ss"
                "awk"
              ];
            };
            source = {
              command = ''ss -tlnp 2>/dev/null | tail -n +2 | awk '{gsub(/.*:/,"",$4); print $4, $1, $6}' | sed "s/users:((\"//; s/\".*//"'';
              display = "{split: :0} ({split: :2})";
            };
            preview.command = "ss -tlnp 2>/dev/null | grep ':{split: :0} ' | head -20";
            ui.preview_panel.size = 40;
            actions.kill = {
              description = "Kill the process listening on the selected port";
              command = "fuser -k {split: :0}/tcp";
              mode = "execute";
            };
          };

          "python-venvs" = {
            metadata = {
              name = "python-venvs";
              description = "Find Python virtual environments";
              requirements = [ "find" ];
            };
            source.command = "find ~ -maxdepth 5 -type f -name 'pyvenv.cfg' 2>/dev/null | xargs -I{} dirname {}";
            preview.command = "cat '{}/pyvenv.cfg' 2>/dev/null && echo '' && echo 'Packages:' && '{}/bin/pip' list --format=columns 2>/dev/null | head -20";
            actions = {
              activate = {
                description = "Open a shell with the selected venv activated";
                command = "source '{}/bin/activate' && $SHELL";
                mode = "execute";
              };
              packages = {
                description = "List all packages in the selected venv";
                command = "'{}/bin/pip' list | less";
                mode = "execute";
              };
            };
          };

          tldr = {
            metadata = {
              name = "tldr";
              description = "Browse and preview TLDR help pages for command-line tools";
              requirements = [ "tldr" ];
            };
            source.command = "tldr --list";
            preview.command = "tldr '{0}' --color always";
            ui.layout = "portrait";
            keybindings."ctrl-e" = "actions:open";
            actions.open = {
              description = "Open the selected TLDR page";
              command = "tldr '{0}'";
              mode = "execute";
            };
          };
        };
      };

      # programs.zsh.initContent = ''
      #   bindkey -s '^S' 'tv --ui-scale 80 sesh\n'
      # '';

      home.packages = with pkgs; [
        fd
        bat
        jq
      ];
    };
}
