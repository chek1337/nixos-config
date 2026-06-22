# Standalone Packages

These packages can be used independently from this NixOS configuration. No NixOS or Home Manager activation is required.

## Neovim (nixvim)

The Neovim configuration is exposed as a standalone flake package.

### Run without installing

```bash
nix run github:chek1337/nixos-config#nvim
```

### Install to user profile

```bash
nix profile install github:chek1337/nixos-config#nvim
```

### Add to your own flake

```nix
{
  inputs.nixos-config.url = "github:chek1337/nixos-config";

  outputs = { nixos-config, nixpkgs, ... }: {
    # Use the built package directly
    packages.x86_64-linux.nvim = nixos-config.packages.x86_64-linux.nvim;
  };
}
```

## tmux

The tmux configuration is exposed as a standalone flake package too: full keybindings, sesh, catppuccin and smart-splits baked in, with the nord palette hardcoded because Stylix is not available off-NixOS.

The config and its plugins are wrapped into the binary via `tmux -f <baked-config>`.

The wrapper also puts the runtime tools the config shells out to on `PATH`
(`sesh`, `tmuxinator`, `tmux-last`, `fzf`, `zoxide`, `eza`, `fd`, `bat`, ...) and
bundles the `television` `sesh` channel (via a wrapped `tv --cable-dir`), so the
session picker (`prefix + s`) and floax popups work off-NixOS without leaking
`XDG_CONFIG_HOME` into pane shells.

**tmuxinator:** the binary is bundled, but no recipes are. Drop your own under
`~/.config/tmuxinator/*.yml` on the target machine.

**Theme/icons:** the rendered config is byte-identical to the desktop host, so
the status bar needs a Nerd Font (for example, JetBrainsMono Nerd Font) and a
truecolor-capable terminal to look right. That is terminal-side, not in this
package. Clipboard/fingers bindings use `wl-copy` and only work under Wayland.

### Run without installing

```bash
nix run github:chek1337/nixos-config#tmux
```

### Install to user profile

```bash
nix profile install github:chek1337/nixos-config#tmux
```

### Add to your own flake

```nix
{
  inputs.nixos-config.url = "github:chek1337/nixos-config";

  outputs = { nixos-config, nixpkgs, ... }: {
    # Use the built package directly
    packages.x86_64-linux.tmux = nixos-config.packages.x86_64-linux.tmux;
  };
}
```

## zoxide

zoxide has no config file. Its setup is purely shell integration
(`eval "$(zoxide init zsh)"`) plus the `cd = z` alias. A `nix profile install`
binary cannot edit a foreign `~/.zshrc`, so the package ships the `zoxide`
binary plus a ready-to-source zsh init with the `cd = z` alias baked in.

### Install to user profile

```bash
nix profile install github:chek1337/nixos-config#zoxide
```

Wire the init in once. Either let the bundled helper do it idempotently:

```bash
zoxide-setup-zsh
```

or add the line by hand:

```bash
echo 'source ~/.nix-profile/share/zoxide/init.zsh' >> ~/.zshrc
```

Either way, new shells then get `z` / `zi` and `cd` jumping like on NixOS.

## kitty

The kitty configuration is exposed as a standalone flake package too: all my
settings, keybindings and the nord palette baked in. As with tmux, the rendered
config is byte-identical to the desktop host, so it just needs a Nerd Font and a
truecolor-capable terminal to look right.

The config is wrapped into the binary via `kitty --config <baked-config>`. The
wrapper also puts the runtime tools the config shells out to on `PATH`
(`fzf`, `zoxide`). The nord palette is hardcoded because Stylix is not available
off-NixOS.

**OpenGL off-NixOS:** kitty is a GPU app, and the Nix build ships its own
`libGL` from `/nix/store`, which on a foreign distro (Ubuntu etc.) fails to find
the host's hardware driver — you get *"OpenGL too old"*. The package fixes this
for **Mesa (Intel/AMD)** by launching kitty through `nixGLIntel`, so it picks up
the host's Mesa driver. No `--impure`, nothing to set up on your side.

For **NVIDIA** there is a separate package, `kitty-nvidia`, that wraps kitty in
`nixGLNvidia`:

```bash
nix run github:chek1337/nixos-config#kitty-nvidia
nix profile install github:chek1337/nixos-config#kitty-nvidia
```

The NVIDIA userspace libs must match the host's kernel-module version, so the
driver version is **pinned** in `packages/kitty-nvidia.nix` (`nvidiaVersion`,
currently `580.159.03`). This keeps the package pure (no `--impure`), but when
the host upgrades its NVIDIA driver you must bump `nvidiaVersion` (and re-pin
`nvidiaHash` via `nix-prefetch-url`), else kitty won't start. Check the host's
version with `nvidia-smi --query-gpu=driver_version --format=csv,noheader`.

**kitty-scrollback.nvim:** the `kitty_mod+z` / `mouse_map` bindings point at a
`~/.local/share/nvim/lazy/…` path that only exists with my lazy.nvim setup, so
they are no-ops off-NixOS. kitty still starts fine.

### Run without installing

```bash
nix run github:chek1337/nixos-config#kitty
```

### Install to user profile

```bash
nix profile install github:chek1337/nixos-config#kitty
```

### Add to your own flake

```nix
{
  inputs.nixos-config.url = "github:chek1337/nixos-config";

  outputs = { nixos-config, nixpkgs, ... }: {
    # Use the built package directly
    packages.x86_64-linux.kitty = nixos-config.packages.x86_64-linux.kitty;
  };
}
```

## yazi

The yazi configuration is exposed as a standalone flake package too: all my
settings, keybindings, plugins and previewers baked in, with the nord palette
hardcoded because Stylix is not available off-NixOS. As with tmux/kitty, the
rendered config is byte-identical to the desktop host.

The whole rendered `yazi/` tree (`yazi.toml`, `keymap.toml`, `theme.toml`,
`init.lua` and every plugin under `plugins/`) is baked into the store and the
binary is wrapped to read it via `YAZI_CONFIG_HOME`. The wrapper also puts the
runtime tools the config and plugins shell out to on `PATH`: the upstream
`pkgs.yazi` wrapper already bundles the base preview deps (`file`, `ffmpeg`,
`7z`, `jq`, `resvg`, `poppler`, …); on top of that we add what my config needs —
`glow`, `hexyl`, `sqlite`, `duckdb`, `ouch`, `mediainfo`, `pandoc`,
`imagemagick`, `transmission`, `trash-cli`, `udisks2`, `p7zip`, `zip`,
`wl-clipboard`/`xclip` (for `ucp`), plus `bat`, `eza`, `ripgrep`, `fd`, `fzf`,
`zoxide` and `television` (the `<Space>ff` files picker and grep search).

**Editor integration:** the `tv-sel` / `tv-grep` search bindings open the hit in
`nvim` (the path is hardcoded in Lua), so those need `nvim` on the target host.
The `NVIM_CWD` branches of the routers only fire when yazi is launched from
inside my nixvim, so they are inert in standalone. yazi itself starts fine
without either.

### Run without installing

```bash
nix run github:chek1337/nixos-config#yazi
```

### Install to user profile

```bash
nix profile install github:chek1337/nixos-config#yazi
```

### Add to your own flake

```nix
{
  inputs.nixos-config.url = "github:chek1337/nixos-config";

  outputs = { nixos-config, nixpkgs, ... }: {
    # Use the built package directly
    packages.x86_64-linux.yazi = nixos-config.packages.x86_64-linux.yazi;
  };
}
```

## zsh

The whole zsh setup is exposed as a standalone flake package too: my `.zshrc` /
`.zshenv` with oh-my-zsh, autosuggestions, syntax-highlighting, the granular
word-deletion (z4h) bindings, OSC 133 prompt markers, fzf/zoxide/direnv
integration, starship and the `eza` / `cd = z` aliases — all baked in. The
rendered dotfiles are byte-identical to the desktop host.

The dotfiles are collected into the store and the binary is wrapped to read them
via `ZDOTDIR`, so your machine's real `~/.zshrc` is **not** read (see
"Extending it" below). The wrapper also sets `STARSHIP_CONFIG` to the baked
`starship.toml` and puts the runtime tools the config shells out to on `PATH`
(`fzf`, `zoxide`, `eza`, `starship`, `direnv`, `git`). The nord palette is not
needed here — colors come from starship and syntax-highlighting themselves.

**History:** `HISTFILE` is rewritten to `$HOME/.zsh_history`, so history lands in
the target user's real home, not the build-time stub home.

### Run without installing

```bash
nix run github:chek1337/nixos-config#zsh
```

### Install to user profile

```bash
nix profile install github:chek1337/nixos-config#zsh
```

The wrapped binary then lives at `~/.nix-profile/bin/zsh`.

### Set it as your default shell

`chsh` only accepts shells listed in `/etc/shells`, so register the profile
binary once, then switch to it (both need `sudo` / your password):

```bash
command -v zsh | sudo tee -a /etc/shells      # ~/.nix-profile/bin/zsh
chsh -s "$(command -v zsh)"
```

Log out and back in for the login shell to change. If you can't edit
`/etc/shells` (no root, locked-down host), keep your current login shell and
chain into this one instead — append to the existing rc (`~/.bashrc`,
distro `~/.zshrc`, …):

```bash
exec ~/.nix-profile/bin/zsh
```

### Extending it

Because `ZDOTDIR` points at the immutable store dir, editing your machine's
`~/.zshrc` does nothing — zsh never reads it. Instead, the baked `.zshrc` sources
`~/.zshrc.local` at the very end (after oh-my-zsh and zoxide), so put your
machine-specific additions there:

```bash
cat >> ~/.zshrc.local <<'EOF'
export PATH="$HOME/bin:$PATH"
alias gs='git status'
EOF
```

New shells pick it up automatically; the store config stays untouched.

### Add to your own flake

```nix
{
  inputs.nixos-config.url = "github:chek1337/nixos-config";

  outputs = { nixos-config, nixpkgs, ... }: {
    # Use the built package directly
    packages.x86_64-linux.zsh = nixos-config.packages.x86_64-linux.zsh;
  };
}
```
