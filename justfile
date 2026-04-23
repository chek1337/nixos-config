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
alias swi := switch-interactive
alias nsw := nixos-switch
alias nswi := nixos-switch-interactive
alias hm := home-manager-switch
alias hmi := home-manager-switch-interactive
alias hmo := home-manager-switch-offline
alias hmoi := home-manager-switch-offline-interactive
alias t := test
alias ti := test-interactive
alias b := build
alias bi := build-interactive
alias bo := boot
alias boi := boot-interactive
alias nbo := nixos-boot
alias nboi := nixos-boot-interactive
alias up := update
alias upi := update-interactive
alias qs := quickshell-reload
alias hw := gen-hardware
alias hwi := gen-hardware-interactive
alias iso := build-iso
alias isoi := build-iso-interactive

# Stage all changes
[private]
stage:
    git add .

# Reload tmux config if server is running
[private]
tmux-reload:
    tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true

# Apply NixOS + Home Manager configuration
[group("deploy")]
switch hostname: stage
    sudo nixos-rebuild switch --flake "{{flake}}#{{hostname}}" {{features_flags}}
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}" {{features_flags}}
    just tmux-reload

# Apply NixOS + Home Manager interactively
[group("deploy")]
switch-interactive: stage
    just switch $(ls modules/hosts | fzf --prompt="switch > ")

# Apply NixOS configuration only
[group("deploy")]
nixos-switch hostname: stage
    sudo nixos-rebuild switch --flake "{{flake}}#{{hostname}}" {{features_flags}}

# Apply NixOS configuration only interactively
[group("deploy")]
nixos-switch-interactive: stage
    just nixos-switch $(ls modules/hosts | fzf --prompt="nixos-switch > ")

# Restart quickshell / noctalia-shell
[group("utils")]
quickshell-reload:
    systemd-run --user --no-block --setenv=PATH="$PATH" -- bash -c 'pids=$$(pgrep -f quickshell | grep -v $$$$); echo "$pids" | xargs -r kill -9; sleep 0.5; noctalia-shell'

# Apply Home Manager configuration only
[group("deploy")]
home-manager-switch hostname: stage
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}" {{features_flags}}
    just tmux-reload

# Apply Home Manager interactively
[group("deploy")]
home-manager-switch-interactive: stage
    just home-manager-switch $(ls modules/hosts | fzf --prompt="hm switch > ")

# Apply Home Manager with fallback when substituters are unreachable
[group("deploy")]
home-manager-switch-offline hostname: stage
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}" {{features_flags}} {{offline_flags}}
    just tmux-reload

# Apply Home Manager offline interactively
[group("deploy")]
home-manager-switch-offline-interactive: stage
    just home-manager-switch-offline $(ls modules/hosts | fzf --prompt="hm switch offline > ")

# Apply NixOS on next boot + Home Manager now
[group("deploy")]
boot hostname: stage
    sudo nixos-rebuild boot --flake "{{flake}}#{{hostname}}" {{features_flags}}
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}" {{features_flags}}
    just tmux-reload

# Apply NixOS on next boot + Home Manager now interactively
[group("deploy")]
boot-interactive: stage
    just boot $(ls modules/hosts | fzf --prompt="boot > ")

# Apply NixOS on next boot only
[group("deploy")]
nixos-boot hostname: stage
    sudo nixos-rebuild boot --flake "{{flake}}#{{hostname}}" {{features_flags}}

# Apply NixOS on next boot only interactively
[group("deploy")]
nixos-boot-interactive: stage
    just nixos-boot $(ls modules/hosts | fzf --prompt="nixos-boot > ")

# Test configuration without applying
[group("deploy")]
test hostname: stage
    sudo nixos-rebuild test --flake "{{flake}}#{{hostname}}" {{features_flags}}

# Test interactively
[group("deploy")]
test-interactive: stage
    just test $(ls modules/hosts | fzf --prompt="test > ")

# Build configuration without applying
[group("deploy")]
build hostname: stage
    nixos-rebuild build --flake "{{flake}}#{{hostname}}" {{features_flags}}

# Build interactively
[group("deploy")]
build-interactive: stage
    just build $(ls modules/hosts | fzf --prompt="build > ")

# Generate hardware config for current machine
[group("utils")]
gen-hardware hostname: stage
    sudo nixos-generate-config --show-hardware-config \
        > "modules/hosts/{{hostname}}/_hardware-configuration.nix"
    @echo "Saved to modules/hosts/{{hostname}}/_hardware-configuration.nix"

# Generate hardware config interactively
[group("utils")]
gen-hardware-interactive: stage
    just gen-hardware $(ls modules/hosts | fzf --prompt="gen-hardware > ")

# Check flake
[group("utils")]
check: stage
    nix flake check {{features_flags}}

# Update all inputs or a specific one: just up / just up <input>
[group("utils")]
update *input: stage
    @if [ -z "{{input}}" ]; then nix flake update {{features_flags}}; else nix flake update {{input}} {{features_flags}}; fi

# Update specific input interactively via fzf
[group("utils")]
update-interactive: stage
    just update $(jq -r '.nodes | keys[] | select(. != "root")' flake.lock | fzf --prompt="update input > ")

# Remove old generations
[group("utils")]
gc: stage
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Build offline installation ISO
[group("iso")]
build-iso hostname: stage
    nix build ".#nixosConfigurations.iso-{{hostname}}.config.system.build.isoImage" -o result-iso --show-trace {{features_flags}}
    @echo "ISO: $(readlink result-iso)/iso/*.iso"

# Build ISO interactively
[group("iso")]
build-iso-interactive: stage
    just build-iso $(ls modules/hosts | fzf --prompt="build-iso > ")

# Format all nix files
[group("utils")]
fmt:
    find . -name "*.nix" -not -path "./.git/*" | xargs nixfmt
    just stage
