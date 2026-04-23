flake := "."
username := "chek"
# Enable flakes + nix-command even if they aren't set in nix.conf
features_flags := '--option extra-experimental-features "nix-command flakes"'
# Flags to fall back to local build when substituters are unreachable
offline_flags := "--option substitute false --option fallback true"

# Show all available commands
default:
    @just --list

alias sw := switch
alias bo := boot
alias t := test
alias b := build
alias up := update
alias qs := quickshell-reload
alias hw := gen-hardware
alias iso := build-iso

# Stage all changes
[private]
stage:
    git add .

# Reload tmux config if server is running
[private]
tmux-reload:
    tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true

# Parse args: keywords `interactive`, `offline`, `nixos`, `hm`; other = hostname.
# Emits shell assignments for caller's `eval`.
[private]
_parse prompt *args:
    #!/usr/bin/env bash
    set -euo pipefail
    hostname="" offline="" force=0 target=""
    for a in {{ args }}; do
        case "$a" in
            interactive) force=1 ;;
            offline) offline='{{ offline_flags }}' ;;
            nixos|hm)
                if [ -n "$target" ]; then
                    echo "error: conflicting targets ('$target' and '$a')" >&2
                    exit 1
                fi
                target="$a"
                ;;
            *)
                if [ -n "$hostname" ]; then
                    echo "error: multiple hostnames ('$hostname' and '$a')" >&2
                    exit 1
                fi
                hostname="$a"
                ;;
        esac
    done
    [ -z "$target" ] && target="both"
    if [ -z "$hostname" ] || [ "$force" = "1" ]; then
        hostname=$(ls modules/hosts | fzf --prompt="{{ prompt }} > ")
    fi
    printf 'HOSTNAME=%q OFFLINE=%q TARGET=%q\n' "$hostname" "$offline" "$target"

# Apply configuration. Args: [hostname] [interactive] [offline] [nixos|hm]
[group("deploy")]
switch *args: stage
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _parse switch {{ args }})"
    total=1; [ "$TARGET" = "both" ] && total=2
    step=1
    if [ "$TARGET" = "nixos" ] || [ "$TARGET" = "both" ]; then
        printf '\n\033[1;34m==> [%d/%d] nixos-rebuild switch (%s)\033[0m\n' "$step" "$total" "$HOSTNAME"
        sudo nixos-rebuild switch --flake "{{ flake }}#$HOSTNAME" {{ features_flags }} $OFFLINE
        step=$((step+1))
    fi
    if [ "$TARGET" = "hm" ] || [ "$TARGET" = "both" ]; then
        printf '\n\033[1;34m==> [%d/%d] home-manager switch (%s@%s)\033[0m\n' "$step" "$total" "{{ username }}" "$HOSTNAME"
        nix run home-manager -- switch --flake "{{ flake }}#{{ username }}@$HOSTNAME" {{ features_flags }} $OFFLINE
    fi
    printf '\n\033[1;32m==> done\033[0m\n'
    just tmux-reload

# Apply NixOS on next boot (+ Home Manager now by default). Args: [hostname] [interactive] [offline] [nixos|hm]
[group("deploy")]
boot *args: stage
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _parse boot {{ args }})"
    total=1; [ "$TARGET" = "both" ] && total=2
    step=1
    if [ "$TARGET" = "nixos" ] || [ "$TARGET" = "both" ]; then
        printf '\n\033[1;34m==> [%d/%d] nixos-rebuild boot (%s)\033[0m\n' "$step" "$total" "$HOSTNAME"
        sudo nixos-rebuild boot --flake "{{ flake }}#$HOSTNAME" {{ features_flags }} $OFFLINE
        step=$((step+1))
    fi
    if [ "$TARGET" = "hm" ] || [ "$TARGET" = "both" ]; then
        printf '\n\033[1;34m==> [%d/%d] home-manager switch (%s@%s)\033[0m\n' "$step" "$total" "{{ username }}" "$HOSTNAME"
        nix run home-manager -- switch --flake "{{ flake }}#{{ username }}@$HOSTNAME" {{ features_flags }} $OFFLINE
    fi
    printf '\n\033[1;32m==> done\033[0m\n'
    just tmux-reload

# Test configuration without applying (nixos only). Args: [hostname] [interactive] [offline]
[group("deploy")]
test *args: stage
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _parse test {{ args }})"
    sudo nixos-rebuild test --flake "{{ flake }}#$HOSTNAME" {{ features_flags }} $OFFLINE

# Build configuration without applying (nixos only). Args: [hostname] [interactive] [offline]
[group("deploy")]
build *args: stage
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _parse build {{ args }})"
    nixos-rebuild build --flake "{{ flake }}#$HOSTNAME" {{ features_flags }} $OFFLINE

# Restart quickshell / noctalia-shell
[group("utils")]
quickshell-reload:
    systemd-run --user --no-block --setenv=PATH="$PATH" -- bash -c 'pids=$$(pgrep -f quickshell | grep -v $$$$); echo "$pids" | xargs -r kill -9; sleep 0.5; noctalia-shell'

# Generate hardware config for current machine. Args: [hostname] [interactive]
[group("utils")]
gen-hardware *args: stage
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _parse gen-hardware {{ args }})"
    sudo nixos-generate-config --show-hardware-config \
        > "modules/hosts/$HOSTNAME/_hardware-configuration.nix"
    echo "Saved to modules/hosts/$HOSTNAME/_hardware-configuration.nix"

# Check flake
[group("utils")]
check: stage
    nix flake check {{ features_flags }}

# Update flake inputs. Args: [input] [interactive]
[group("utils")]
update *args: stage
    #!/usr/bin/env bash
    set -euo pipefail
    input="" force=0
    for a in {{ args }}; do
        case "$a" in
            interactive) force=1 ;;
            *)
                if [ -n "$input" ]; then
                    echo "error: multiple inputs ('$input' and '$a')" >&2
                    exit 1
                fi
                input="$a"
                ;;
        esac
    done
    if [ "$force" = "1" ]; then
        input=$(jq -r '.nodes | keys[] | select(. != "root")' flake.lock | fzf --prompt="update input > ")
    fi
    if [ -z "$input" ]; then
        nix flake update {{ features_flags }}
    else
        nix flake update "$input" {{ features_flags }}
    fi

# Remove old generations
[group("utils")]
gc: stage
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Build offline installation ISO. Args: [hostname] [interactive] [offline]
[group("iso")]
build-iso *args: stage
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _parse build-iso {{ args }})"
    nix build ".#nixosConfigurations.iso-$HOSTNAME.config.system.build.isoImage" -o result-iso --show-trace {{ features_flags }} $OFFLINE
    echo "ISO: $(readlink result-iso)/iso/*.iso"

# Format all nix files
[group("utils")]
fmt:
    find . -name "*.nix" -not -path "./.git/*" | xargs nixfmt
    just stage
