# SOPS in this repo

How to add and edit encrypted secrets. Configuration lives in `.sops.yaml`;
encrypted files live in `secrets/`.

## What is configured

`.sops.yaml` declares one recipient and one creation rule:

```yaml
keys:
  - &chek age1dl0a5av78sz58ckchwrpxf3mk8svq3ffwlre54grpcf5xhzd6gfs2dvj6k
creation_rules:
  - path_regex: secrets/.*\.(yaml|conf)$
    key_groups:
      - age:
        - *chek
```

Implications:

- Only files under `secrets/` ending in `.yaml` or `.conf` are auto-encrypted
  to the `chek` age recipient.
- The matching private age key must exist on the machine doing the edit.
  Default location: `~/.config/sops/age/keys.txt`.
- Anything outside `secrets/` (or with a different extension) is **not**
  covered by a rule — `sops` will refuse to encrypt it until you add a rule
  or rename the path.

Current encrypted files:

```
secrets/secrets.yaml
secrets/wireguard-isakin.conf
secrets/wireguard-laptop-asus.conf
secrets/wireguard-desktop-home.conf
```

## Prerequisites

Confirm the age private key is present:

```sh
test -f ~/.config/sops/age/keys.txt && echo OK
```

If it is missing, restore it from your backup before doing anything else —
without it, every file in `secrets/` is unreadable.

## Editing `secrets.yaml` (add / change a password)

Run `sops` against the file. It decrypts into `$EDITOR`, you save, it
re-encrypts on exit:

```sh
sops secrets/secrets.yaml
```

Inside the editor it is plain YAML. Add or change keys like:

```yaml
wifi_password: hunter2
api_tokens:
  github: ghp_xxxxxxxxxxxxxxxxxxxx
  cloudflare: cf-xxxxxxxxxxxxxxxx
```

Save and quit. SOPS rewrites `secrets/secrets.yaml` with the new ciphertext
and updated MAC. Commit the result:

```sh
git add secrets/secrets.yaml
git diff --cached secrets/secrets.yaml   # sanity-check: only ciphertext changed
git commit -m "secrets: add wifi_password"
```

Tip — to change one key without opening an editor:

```sh
sops set secrets/secrets.yaml '["wifi_password"]' '"hunter3"'
```

## Adding a new encrypted file

The path must match `secrets/.*\.(yaml|conf)$` for the creation rule to fire.

### New YAML secret

```sh
sops secrets/new-thing.yaml
```

This opens an empty file in `$EDITOR` already wired up for encryption. Add
keys, save, exit. The file is written encrypted.

### New `.conf` file (e.g. a WireGuard config)

Two equivalent flows.

**A. Encrypt an existing plaintext file in-place:**

```sh
# write plaintext somewhere OUTSIDE the repo first
sops --encrypt /tmp/wg-newhost.conf > secrets/wireguard-newhost.conf
shred -u /tmp/wg-newhost.conf
```

**B. Start empty and edit:**

```sh
sops secrets/wireguard-newhost.conf
# paste the conf body, save, quit
```

Confirm it is encrypted before committing:

```sh
head -n 3 secrets/wireguard-newhost.conf
# should NOT look like a plain WireGuard config — expect base64/ciphertext blocks
```

Then commit.

## Viewing without editing

```sh
sops -d secrets/secrets.yaml                 # print decrypted YAML to stdout
sops -d secrets/wireguard-desktop-home.conf  # same for a conf file
```

Pipe to `less`; do not redirect to a file inside the repo.

## Rotating / re-keying

If you ever add another age recipient (e.g. a second machine), update
`.sops.yaml` first, then re-encrypt every existing file so the new key is
embedded:

```sh
sops updatekeys secrets/secrets.yaml
sops updatekeys secrets/wireguard-isakin.conf
sops updatekeys secrets/wireguard-laptop-asus.conf
sops updatekeys secrets/wireguard-desktop-home.conf
```

`updatekeys` only refreshes recipients; it does not change the secret
values, so the diff should be limited to key metadata.

## Rules of thumb

- **Never** `git add` a plaintext file under `secrets/`. If you did by
  mistake, `git restore --staged` it, scrub the working copy, and rotate
  the leaked value.
- Keep filenames matching the regex (`secrets/<name>.yaml` or
  `secrets/<name>.conf`). Other names will not auto-encrypt.
- One logical secret per file when it has its own consumer (WireGuard
  peer, app config). Group small key/value secrets into `secrets.yaml`.
- The committed diff for an edited secret should be ciphertext + a bumped
  `lastmodified` / `mac` field — if you see plaintext in the diff, stop
  and investigate before pushing.
