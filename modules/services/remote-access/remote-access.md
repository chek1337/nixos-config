# Remote access

Personal playbook for the `remote-access` aggregate module
(`modules/services/remote-access/`). Three independent submodules,
toggled per host via `settings.*` flags:

| Submodule | Flag | What it does |
|-----------|------|--------------|
| `openssh` | `enableRemoteSsh` | sshd on `remoteSshPort` (default 22), key-only, no root, no X11. SFTP comes bundled. |
| `sunshine` | `enableRemoteDesktop` | Sunshine streaming server + firewall (TCP 47984/47989/47990, UDP 47998-48000, 48010). Auto-start enabled. |
| `moonlight` | `enableMoonlightClient` | Installs `moonlight-qt` only. Independent of the server. |

A host can be only client, only server, or both. To enable any of them
the host must import the `remote-access` profile (`modules` list in
`modules/hosts/<host>/host.nix`).

## Current topology

| Host          | SSH server | Sunshine server | Moonlight client |
|---------------|:----------:|:---------------:|:----------------:|
| desktop-home  | yes        | yes             | yes              |
| desktop-work  | no (ready) | no (ready)      | no               |
| laptop-asus   | no         | no              | yes              |

`desktop-work` imports the module but both server flags are `false` —
flip them in `modules/hosts/desktop-work/host.nix` when it is time to
enable office access.

## Per-host wiring (template)

In `modules/hosts/<host>/host.nix`:

```nix
modules = [
  # ...
  "remote-access"
];
sharedSettings = {
  # ...
  enableRemoteSsh = true;            # server
  enableRemoteDesktop = true;        # server
  enableMoonlightClient = true;      # client
  remoteSshAuthorizedKeys = [
    "ssh-ed25519 AAAA... user@client-host"
  ];
};
```

`remoteSshPort` overrides the default 22 (the firewall hole follows
the option automatically).

## SSH access

### 1. Get the client's public key

On the **client** (the host that will connect *out*):

```bash
ls ~/.ssh/*.pub
# if missing:
ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f ~/.ssh/id_ed25519
cat ~/.ssh/<key>.pub
```

### 2. Authorize it on the server

Append the line to `remoteSshAuthorizedKeys` in the server host's
`host.nix`, commit, then on the server:

```bash
just sw <server-host>   # first apply must be physical — sshd not up yet
```

### 3. Test from the client

```bash
ssh -i ~/.ssh/<key> chek@<SERVER_IP>
# verbose if it fails:
ssh -vv -i ~/.ssh/<key> chek@<SERVER_IP>
```

Find `<SERVER_IP>` on the server:

```bash
ip -4 addr show | awk '/inet / && !/127/ {print $2}'
```

## Sunshine / Moonlight (graphical streaming)

### 1. First-time server setup (on the Sunshine host)

```bash
xdg-open "https://localhost:47990"
```

Accept the self-signed cert. Create the admin user (Sunshine-local
credentials, used only for the web UI / pairing).

Verify the service is alive:

```bash
systemctl --user status sunshine
```

It must be `active (running)` under a live graphical session. If it
started before the compositor, restart it once logged in:

```bash
systemctl --user restart sunshine
```

### 2. Pairing the client

On the **client** with `enableMoonlightClient = true`:

```bash
moonlight
```

In the UI:

1. `Add Host` (`+`) → `<SERVER_IP>` → save.
2. Click the host tile — Moonlight shows a 4-digit **PIN**.
3. From any browser, open `https://<SERVER_IP>:47990` (or
   `localhost` if on the server). Log in to Sunshine.
4. `PIN` tab → enter the code (~3 min before it expires) → `Send`.
5. Back in Moonlight, click the host again → `Desktop` tile → stream.

Pairing is persistent — step 2 onward is one-shot per client.

### 3. Quality knobs (Moonlight side)

Resolution / bitrate / framerate are set per-host in Moonlight's
`Settings`. Defaults are usually fine on LAN; on slow links drop the
bitrate first, then resolution.

## Local network test (laptop-asus → desktop-home)

1. Both hosts on the same Wi-Fi / LAN.
2. `just sw desktop-home` (physical, first time).
3. `just sw laptop-asus`.
4. `ssh -i ~/.ssh/<key> chek@<HOME_IP>` — should drop into a shell.
5. Sunshine web UI on `https://<HOME_IP>:47990` from laptop-asus —
   should load.
6. `moonlight` on laptop-asus → pair → stream.

## Troubleshooting

| Symptom | Likely cause | Check |
|---------|--------------|-------|
| `ssh: connection refused` | sshd not running | `systemctl status sshd` on server |
| `ssh: permission denied (publickey)` | key not authorized / wrong key file | `journalctl -u sshd -e` on server, `ssh -vv` on client |
| Sunshine web UI unreachable from client | firewall didn't open 47990 | `ss -tlnp \| grep 47990`, `sudo nft list ruleset \| grep 47990` |
| Moonlight finds host, `failed to connect` | sunshine.service down | `systemctl --user status sunshine` |
| Stream connects, black screen | sunshine started before compositor | `systemctl --user restart sunshine` under live niri session |
| PIN rejected | expired (~3 min) | regenerate from Moonlight |
| Audio missing | sunshine PipeWire capture not picked up | `systemctl --user restart sunshine`, check `pactl list sources` |

Useful logs:

```bash
journalctl -u sshd -e --no-pager        # SSH server
journalctl --user -u sunshine -e        # Sunshine server
```

## Beyond LAN (office / WAN)

The current setup only works on the same broadcast domain. For
office access two clean options:

1. **WireGuard** — already wired (`services/wireguard`,
   `wireguardConfigName`). Bring up the tunnel on both ends and use
   the WG peer IP as `<SERVER_IP>`. No NAT traversal needed, no public
   ports exposed. This is the preferred path.
2. **Port forwarding on the office router** — forward `remoteSshPort`
   (TCP) and Sunshine's ports (TCP 47984/47989/47990, UDP
   47998-48000, 48010) to the workstation. Exposes services to the
   public internet — only do this if a VPN is impossible, and only
   for SSH (Sunshine over the internet is a bad idea).

Either way: re-run the `ssh` and `moonlight` test from §"Local
network test" using the new `<SERVER_IP>`.
