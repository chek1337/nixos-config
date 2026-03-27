flake := "."
username := "chek"

# Show all available commands
default:
    @just --list

alias sw := switch
alias swi := switch-interactive
alias t := test
alias ti := test-interactive
alias b := build
alias bi := build-interactive
alias bo := boot
alias boi := boot-interactive
alias hm := home-manager-switch
alias hmi := home-manager-switch-interactive
alias a := apply-all
alias ai := apply-all-interactive
alias up := update
alias hw := gen-hardware
alias hwi := gen-hardware-interactive
alias iso := build-iso
alias isoi := build-iso-interactive

# Stage all changes
[private]
stage:
    git add .

# Apply configuration for the current host
[group("deploy")]
switch hostname: stage
    sudo nixos-rebuild switch --flake "{{flake}}#{{hostname}}"

# Interactively select host and apply
[group("deploy")]
switch-interactive: stage
    just switch $(ls modules/hosts | fzf --prompt="switch > ")

# Apply Home Manager configuration for a host
[group("deploy")]
home-manager-switch hostname: stage
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}"

# Apply Home Manager interactively
[group("deploy")]
home-manager-switch-interactive: stage
    just home-manager-switch $(ls modules/hosts | fzf --prompt="hm switch > ")

# Apply both NixOS and Home Manager configuration
[group("deploy")]
apply-all hostname: stage
    sudo nixos-rebuild switch --flake "{{flake}}#{{hostname}}"
    nix run home-manager -- switch --flake "{{flake}}#{{username}}@{{hostname}}"

# Apply both interactively
[group("deploy")]
apply-all-interactive: stage
    just apply-all $(ls modules/hosts | fzf --prompt="apply all > ")

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

# Apply configuration on next boot
[group("deploy")]
boot hostname: stage
    sudo nixos-rebuild boot --flake "{{flake}}#{{hostname}}"

# Apply configuration on next boot interactively
[group("deploy")]
boot-interactive: stage
    just boot $(ls modules/hosts | fzf --prompt="boot > ")

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
