<div align="center">

# dsh-ctl
Mac 本机 dsh web 服务的命令行控制面

![License](https://img.shields.io/badge/License-MIT-blue) ![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey) ![Shell](https://img.shields.io/badge/Shell-Bash-green)

一条命令管理 launchd 常驻的 dsh web · 断线自动拉回 · 改端口不用手编 plist

[快速开始](#-快速开始) · [命令](#-命令) · [English](README.en.md)

</div>

---

## ✨ 特性

- **launchd 常驻** —— dsh web 由 LaunchAgent 持有，终端关了、App 退了服务都在，崩溃自动拉回
- **一条命令拿访问地址** —— `dsh-ctl open` 直接用默认浏览器打开带 token 的 URL，不用去日志里翻
- **改端口不用手编 plist** —— `dsh-ctl port 3090` 自动改配置、重启服务、打印新地址
- **不挑包管理器** —— 安装时自动探测 pnpm / yarn / npx，装了哪个用哪个，都没有会明确报错
- **接管已有进程** —— 之前手动起的 dsh web，`dsh-ctl adopt` 一次性切到 launchd 接管
- **单文件** —— 一个 Bash 脚本，无依赖，读一遍就能放心用

## 🚀 快速开始

要求：macOS + pnpm / yarn 2+ / npx 任一（自动探测，推荐 pnpm）。

### 1. 安装

```bash
git clone https://github.com/johnhom1024/dsh-ctl.git
cd dsh-ctl && ./install.sh
```

装完自动做环境预检（node / 包管理器），缺什么会告诉你。

### 2. 部署服务

```bash
dsh-ctl install   # 写入 LaunchAgent（幂等，可重复执行）
dsh-ctl start     # 启动，dsh web 跑在 launchd 下
```

### 3. 打开

```bash
dsh-ctl open
```

浏览器会打开 `http://127.0.0.1:3080/?token=...`，开箱即用。遇到问题先跑 `dsh-ctl doctor`，逐项体检告诉你差在哪。

<details>
<summary>已有手动起的 dsh web，想迁移过来</summary>

```bash
dsh-ctl adopt
```

会杀掉现有进程链并让 launchd 接管，浏览器会话断线重连即可。

</details>

## ⚙️ 命令

| 命令 | 作用 |
|------|------|
| `status` | launchd job 状态、端口监听、进程归属检查 |
| `url` | 打印带 token 的访问 URL |
| `open` | 默认浏览器打开 token URL |
| `port` | 查看当前端口 |
| `port N` | 改端口：改 plist + 重启 + 打印新 URL |
| `log` | tail -f 服务日志 |
| `start` / `stop` | 启动 / 真停（stop 不会被拉回） |
| `restart` | 重启（kickstart -k） |
| `adopt` | 把宿主手动拉起的进程切到 launchd 接管 |
| `install` | 写入/修复 LaunchAgent plist（幂等） |
| `doctor` | 环境自检：node / 包管理器 / plist / launchd / 端口 / token |

环境变量 `DSH_CTL_PORT` 可临时覆盖端口（默认读 plist，plist 缺省 3080）。

## 📄 License

MIT
