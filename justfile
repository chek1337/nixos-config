flake := "."
username := "chek"

# Show all available commands
default:
    @just --list

alias sw := switch
alias swi := switch-interactive
alias nsw := nixos-switch
alias nswi := nixos-switch-interactive
alias hm := home-manager-switch
alias hmi := home-manager-switch-interactive
alias t := test
alias ti := test-interactive
alias b := build
alias bi := build-interactive
alias bo := boot
alias boi := boot-interactive
alias nbo := nixos-boot
alias nboi := nixos-boot-interactive
alias up := update
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
    sudo nixos-rebuild switch --flake "{{flake}}#{{hostname}}"
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}"
    just tmux-reload

# Apply NixOS + Home Manager interactively
[group("deploy")]
switch-interactive: stage
    just switch $(ls modules/hosts | fzf --prompt="switch > ")

# Apply NixOS configuration only
[group("deploy")]
nixos-switch hostname: stage
    sudo nixos-rebuild switch --flake "{{flake}}#{{hostname}}"

# Apply NixOS configuration only interactively
[group("deploy")]
nixos-switch-interactive: stage
    just nixos-switch $(ls modules/hosts | fzf --prompt="nixos-switch > ")

# Apply Home Manager configuration only
[group("deploy")]
home-manager-switch hostname: stage
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}"
    just tmux-reload

# Apply Home Manager interactively
[group("deploy")]
home-manager-switch-interactive: stage
    just home-manager-switch $(ls modules/hosts | fzf --prompt="hm switch > ")

# Apply NixOS on next boot + Home Manager now
[group("deploy")]
boot hostname: stage
    sudo nixos-rebuild boot --flake "{{flake}}#{{hostname}}"
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}"
    just tmux-reload

# Apply NixOS on next boot + Home Manager now interactively
[group("deploy")]
boot-interactive: stage
    just boot $(ls modules/hosts | fzf --prompt="boot > ")

# Apply NixOS on next boot only
[group("deploy")]
nixos-boot hostname: stage
    sudo nixos-rebuild boot --flake "{{flake}}#{{hostname}}"

# Apply NixOS on next boot only interactively
[group("deploy")]
nixos-boot-interactive: stage
    just nixos-boot $(ls modules/hosts | fzf --prompt="nixos-boot > ")

# Test configuration without applying
[group("deploy")]
test hostname: stage
    sudo nixos-rebuild test --flake "{{flake}}#{{hostname}}"

# Test interactively
[group("deploy")]
test-interactive: stage
    just test $(ls modules/hosts | fzf --prompt="test > ")

# Build configuration without applying
[group("deploy")]
build hostname: stage
    nixos-rebuild build --flake "{{flake}}#{{hostname}}"

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
    nix flake check

# Update all inputs
[group("utils")]
update: stage
    nix flake update

# Update specific input
[group("utils")]
update-input input: stage
    nix flake update {{input}}

# Remove old generations
[group("utils")]
gc: stage
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Build offline installation ISO
[group("iso")]
build-iso hostname: stage
    nix build ".#nixosConfigurations.iso-{{hostname}}.config.system.build.isoImage" -o result-iso --show-trace
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
