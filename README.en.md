<div align="center">

# dsh-ctl
A command-line control plane for your local dsh web service on macOS

![License](https://img.shields.io/badge/License-MIT-blue) ![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey) ![Shell](https://img.shields.io/badge/Shell-Bash-green)

One command to manage a launchd-supervised dsh web · auto-restart on crash · change ports without editing plists

[Quick Start](#-quick-start) · [Commands](#-commands) · [中文](README.md)

</div>

---

## ✨ Features

- **launchd-supervised** — dsh web is owned by a LaunchAgent; close the terminal, quit the app, the service stays. Crashes are auto-restarted; auto-starts at login by default, `dsh-ctl autostart off` to disable
- **One command for the URL** — `dsh-ctl open` opens the token-authenticated URL in your default browser, no digging through logs
- **Change ports without editing plists** — `dsh-ctl port 3090` rewrites the config, restarts the service, and prints the new URL
- **One-command upgrades** — `dsh-ctl upgrade` compares against the newest remote release, purges pnpm's stale metadata cache (which causes "fake upgrades"), pre-downloads and verifies the new version, then restarts and reads back the running version to confirm
- **Works with any package manager** — install-time detection for pnpm / yarn / npx; uses whichever you have, errors clearly if none
- **Adopt existing processes** — started dsh web by hand earlier? `dsh-ctl adopt` switches it to launchd in one shot
- **Single file** — one Bash script, zero dependencies, readable in one pass

## 🚀 Quick Start

Requires: macOS + any of pnpm / yarn 2+ / npx (auto-detected; pnpm recommended).

### 1. Install

```bash
git clone https://github.com/johnhom1024/dsh-ctl.git
cd dsh-ctl && ./install.sh
```

The installer runs a quick environment check (node / package manager) and tells you what's missing.

### 2. Deploy the service

```bash
dsh-ctl install   # writes the LaunchAgent (idempotent, safe to re-run)
dsh-ctl start     # starts dsh web under launchd
```

### 3. Open

```bash
dsh-ctl open
```

Your browser opens `http://127.0.0.1:3080/?token=...` — ready to use. If anything goes wrong, run `dsh-ctl doctor` for a step-by-step health check.

<details>
<summary>Already running dsh web by hand and want to migrate?</summary>

```bash
dsh-ctl adopt
```

This kills the existing process chain and hands it to launchd; reconnect your browser session afterwards.

</details>

## ⚙️ Commands

| Command | What it does |
|---------|--------------|
| `status` | launchd job state, port listening, process ownership check |
| `url` | Print the token-authenticated URL |
| `open` | Open the token URL in the default browser |
| `port` | Show the current port |
| `port N` | Change port: rewrites plist + restarts + prints the new URL |
| `channel` | Show/switch release channel (latest / next / exact version) |
| `upgrade` | Upgrade to the newest version of the current channel (purge cache + verify download + restart + check) |
| `upgrade <version>` | Upgrade/downgrade to an exact version (pins the plist channel; go back to rolling with `channel latest`) |
| `autostart` | Auto-start at login toggle (`autostart on/off`, default on) |
| `log` | tail -f the service log |
| `start` / `stop` | Start / real stop (stop won't be respawned) |
| `restart` | Restart (kickstart -k) |
| `adopt` | Hand a manually-started process over to launchd |
| `install` | Write/repair the LaunchAgent plist (idempotent) |
| `doctor` | Health check: node / package manager / plist / launchd / port / token |

Environment variables: `DSH_CTL_PORT` overrides the port (default: read from the plist, falling back to 3080); `DSH_CTL_LABEL` / `DSH_CTL_LOG` override the LaunchAgent label and log path (useful for isolated instances).

<details>
<summary>What dsh-ctl upgrade actually does (and why a plain restart isn't enough)</summary>

1. Reads the **currently running version** from the listening process and compares it with the target from the official npmjs registry (when your local registry is a mirror, npmjs is what decides whether an update exists)
2. Purges pnpm's cached registry metadata for `@deepseek-ai/dsh` — pnpm dlx resolves `@latest` from that cache, and a lagging mirror plus an etag 304 can make the snapshot **never refresh**, so a plain restart only "fake-upgrades"
3. Runs `pnpm dlx @deepseek-ai/dsh@<target> --version` to pre-download and verify the new version actually runs (on failure it aborts and **the running service is untouched**)
4. Restarts: `kickstart -k` for in-channel upgrades; for an exact version it rewrites the plist first, then bootout + bootstrap
5. Reads the running version back to confirm the switch; if it didn't switch it tells you the mirror probably hasn't synced yet

When run from inside a dsh web session, the restart cuts that session, so the command schedules a delayed async restart instead and tells you to verify with `dsh-ctl status` after reconnecting. A target that is not newer than the running version is refused by default (no accidental downgrades); force it with `dsh-ctl upgrade <version> --force`.

</details>

## 📄 License

MIT
