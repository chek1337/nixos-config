# nixos config
install

```
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run \
  "ssh-to-age -private-key < ~/.ssh/07_03_26" > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```
