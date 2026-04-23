flake := "."
username := "chek"
# Enable flakes + nix-command even if they aren't set in nix.conf
features_flags := '--option extra-experimental-features "nix-command flakes"'

# Show all available commands
default:
    @just --list

alias sw := switch
alias nsw := nixos-switch
alias hm := home-manager-switch
alias bo := boot
alias nbo := nixos-boot
alias t := test
alias b := build
alias up := update
alias upi := update-interactive
alias qs := quickshell-reload
alias hw := gen-hardware
alias iso := build-iso
alias h := hosts

# Stage all changes
[private]
stage:
    git add .

# Prompt for sudo password upfront and refresh cached credentials
[private]
sudo-refresh:
    sudo -v

# Reload tmux config if server is running
[private]
tmux-reload:
    tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true

# Apply NixOS + Home Manager configuration
[group("deploy")]
switch hostname: stage sudo-refresh
    nh os switch {{ flake }} -H {{ hostname }}
    nh home switch {{ flake }} -c {{ username }}@{{ hostname }}
    just tmux-reload

# Apply NixOS configuration only
[group("deploy")]
nixos-switch hostname: stage sudo-refresh
    nh os switch {{ flake }} -H {{ hostname }}

# Apply Home Manager configuration only
[group("deploy")]
home-manager-switch hostname: stage
    nh home switch {{ flake }} -c {{ username }}@{{ hostname }}
    just tmux-reload

# Apply NixOS on next boot + Home Manager now
[group("deploy")]
boot hostname: stage sudo-refresh
    nh os boot {{ flake }} -H {{ hostname }}
    nh home switch {{ flake }} -c {{ username }}@{{ hostname }}
    just tmux-reload

# Apply NixOS on next boot only
[group("deploy")]
nixos-boot hostname: stage sudo-refresh
    nh os boot {{ flake }} -H {{ hostname }}

# Test configuration without applying
[group("deploy")]
test hostname: stage sudo-refresh
    nh os test {{ flake }} -H {{ hostname }}

# Build configuration without applying
[group("deploy")]
build hostname: stage sudo-refresh
    nh os build {{ flake }} -H {{ hostname }}

# Restart quickshell / noctalia-shell
[group("utils")]
quickshell-reload:
    systemd-run --user --no-block --setenv=PATH="$PATH" -- bash -c 'pids=$$(pgrep -f quickshell | grep -v $$$$); echo "$pids" | xargs -r kill -9; sleep 0.5; noctalia-shell'

# Generate hardware config for given host
[group("utils")]
gen-hardware hostname: stage sudo-refresh
    sudo nixos-generate-config --show-hardware-config \
        > "modules/hosts/{{ hostname }}/_hardware-configuration.nix"
    echo "Saved to modules/hosts/{{ hostname }}/_hardware-configuration.nix"

# List available host configurations
[group("utils")]
hosts:
    @ls -1 modules/hosts

# Check flake
[group("utils")]
check: stage
    nix flake check {{ features_flags }}

# Update flake inputs. Args: [inputs...]
[group("utils")]
update *args: stage
    nix flake update {{ args }} {{ features_flags }}

# Update specific input interactively via fzf
[group("utils")]
update-interactive: stage
    #!/usr/bin/env bash
    set -euo pipefail
    input=$(jq -r '.nodes | keys[] | select(. != "root")' flake.lock | fzf --prompt="update input > ") || exit 0
    [ -z "$input" ] && exit 0
    just update "$input"

# Remove old generations
[group("utils")]
gc: stage
    nh clean all

# Build offline installation ISO
[group("iso")]
build-iso hostname: stage
    nix build ".#nixosConfigurations.iso-{{ hostname }}.config.system.build.isoImage" -o result-iso --show-trace {{ features_flags }}
    echo "ISO: $(readlink result-iso)/iso/*.iso"

# Format all nix files
[group("utils")]
fmt:
    find . -name "*.nix" -not -path "./.git/*" | xargs nixfmt
    just stage
