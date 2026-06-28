flake := "."
username := "chek"
# Enable flakes + nix-command even if they aren't set in nix.conf
features_flags := '--option extra-experimental-features "nix-command flakes"'
offline_flags := "--offline --no-net --no-update-lock-file --option substitute false --builders ''"
# Same, but for nh-based deploy recipes (nh shells out to nix internally
# and doesn't take features_flags) — exported into every recipe's env
export NIX_CONFIG := "experimental-features = nix-command flakes"

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
alias osw := offline-switch
alias ot := offline-test
alias ob := offline-build
alias odb := offline-dry-build
alias up := update
alias upi := update-interactive
alias nr := noctalia-reload
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

# Check offline NixOS build without applying
[group("offline deploy")]
offline-dry-build hostname: stage
    nixos-rebuild dry-build --flake {{ flake }}#{{ hostname }} {{ features_flags }} {{ offline_flags }}

# Build NixOS configuration offline without applying
[group("offline deploy")]
offline-build hostname: stage
    nixos-rebuild build --flake {{ flake }}#{{ hostname }} {{ features_flags }} {{ offline_flags }}

# Test NixOS configuration offline without making it boot default
[group("offline deploy")]
offline-test hostname: stage sudo-refresh
    sudo nixos-rebuild test --flake {{ flake }}#{{ hostname }} {{ features_flags }} {{ offline_flags }}

# Apply NixOS configuration offline
[group("offline deploy")]
offline-switch hostname: stage sudo-refresh
    sudo nixos-rebuild switch --flake {{ flake }}#{{ hostname }} {{ features_flags }} {{ offline_flags }}

# Restart noctalia. v5 is a single native binary (`noctalia`), no longer a
# quickshell QML app, so we kill the `noctalia` process by exact name and
# relaunch it detached (it's spawned by niri, systemd unit disabled). For a
# config-only change use the lighter `noctalia msg config-reload` instead — it
# re-reads config.toml live without a restart.
[group("utils")]
noctalia-reload:
    systemd-run --user --no-block --setenv=PATH="$PATH" -- bash -c 'pkill -x noctalia; sleep 0.5; exec noctalia'

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

# Show diff between current system and previous generation
[group("utils")]
diff-prev:
    #!/usr/bin/env bash
    set -euo pipefail
    current=$(realpath /run/current-system)
    prev=""
    for link in $(printf '%s\n' /nix/var/nix/profiles/system-*-link | sort -V); do
        [ "$(realpath "$link")" = "$current" ] && break
        prev=$link
    done
    [ -n "$prev" ] || { echo "No previous generation found"; exit 1; }
    nvd diff "$prev" /run/current-system

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

# Initial NixOS boot config (first install, standard nixos-rebuild — no nh)
[group("init")]
nboinit hostname: init-hooks sudo-refresh
    sudo nixos-rebuild boot --flake {{ flake }}#{{ hostname }} {{ features_flags }}

# Initial Home Manager activation (first install — home-manager not yet in PATH)
[group("init")]
hminit hostname:
    nix run home-manager {{ features_flags }} -- switch -b backup --flake {{ flake }}#{{ username }}@{{ hostname }}

# Register sops age key derived from an existing SSH private key
[group("init")]
sops-init key:
    mkdir -p ~/.config/sops/age
    ssh-to-age -private-key < ~/.ssh/{{ key }} > ~/.config/sops/age/keys.txt
    chmod 600 ~/.config/sops/age/keys.txt
    echo "Saved age key to ~/.config/sops/age/keys.txt"

# Fix SSH key permissions, (re)load into ssh-agent, verify against GitHub
[group("init")]
ssh-init key:
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/{{ key }}
    chmod 644 ~/.ssh/{{ key }}.pub
    ssh-add -D
    ssh-add ~/.ssh/{{ key }}
    ssh -T git@github.com || true

# Bootstrap Eltex corp proxy for nix-daemon.
# Writes a runtime systemd drop-in under /run/ (NixOS makes /etc/systemd/
# read-only) and restarts the daemon, so subsequent nh builds download
# through the proxy. /run/ is wiped on reboot — re-run after reboot to
# re-enable. Mirrored as the `eltex-proxy-up` zsh function.
[group("init")]
eltex-proxy-up: sudo-refresh
    #!/usr/bin/env bash
    set -euo pipefail
    DIR=/run/systemd/system/nix-daemon.service.d
    sudo mkdir -p "$DIR"
    sudo tee "$DIR/00-eltex-proxy.conf" >/dev/null <<'EOF'
    [Service]
    Environment="http_proxy=http://proxy.eltex.loc:3128"
    Environment="https_proxy=http://proxy.eltex.loc:3128"
    Environment="no_proxy=127.0.0.1,localhost,.eltex.loc"
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart nix-daemon
    echo "nix-daemon now uses http://proxy.eltex.loc:3128 (runtime drop-in)"
    echo "Verify:  systemctl show nix-daemon -p Environment | tr ' ' '\\n' | grep proxy"
    echo "Now run: just bo laptop-asus  (or sw/nboinit/etc.)"

# Remove the runtime proxy override left by `eltex-proxy-up`.
[group("init")]
eltex-proxy-down: sudo-refresh
    sudo rm -f /run/systemd/system/nix-daemon.service.d/00-eltex-proxy.conf
    sudo systemctl daemon-reload
    sudo systemctl restart nix-daemon
    echo "Runtime proxy override removed."

# Install git hooks (post-commit writes .git-commit-msg for boot entry labels)
[group("utils")]
init-hooks:
    #!/usr/bin/env bash
    set -euo pipefail
    [ -d .git ] || { echo "not a git repo"; exit 1; }
    cat > .git/hooks/post-commit <<'HOOK'
    #!/usr/bin/env bash
    [ -n "$_UPDATING_BOOT_LABEL" ] && exit 0
    git log -1 --format=%s > .git-commit-msg
    if ! git diff --quiet -- .git-commit-msg 2>/dev/null; then
      git add .git-commit-msg
      _UPDATING_BOOT_LABEL=1 git commit --amend --no-edit --no-verify
    fi
    HOOK
    chmod +x .git/hooks/post-commit
    echo "installed .git/hooks/post-commit"
