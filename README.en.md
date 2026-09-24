<div align="center">

# dsh-ctl
A command-line control plane for your local dsh web service on macOS

![License](https://img.shields.io/badge/License-MIT-blue) ![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey) ![Shell](https://img.shields.io/badge/Shell-Bash-green)

One command to manage a launchd-supervised dsh web · auto-restart on crash · change ports without editing plists

[Quick Start](#-quick-start) · [Commands](#-commands) · [中文](README.md)

</div>

---

## ✨ Features

- **launchd-supervised** — dsh web is owned by a LaunchAgent; close the terminal, quit the app, the service stays. Crashes are auto-restarted
- **One command for the URL** — `dsh-ctl open` opens the token-authenticated URL in your default browser, no digging through logs
- **Change ports without editing plists** — `dsh-ctl port 3090` rewrites the config, restarts the service, and prints the new URL
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
| `log` | tail -f the service log |
| `start` / `stop` | Start / real stop (stop won't be respawned) |
| `restart` | Restart (kickstart -k) |
| `adopt` | Hand a manually-started process over to launchd |
| `install` | Write/repair the LaunchAgent plist (idempotent) |
| `doctor` | Health check: node / package manager / plist / launchd / port / token |

The `DSH_CTL_PORT` environment variable overrides the port (default: read from the plist, falling back to 3080).

## 📄 License

MIT
