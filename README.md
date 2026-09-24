<div align="center">

# dsh-ctl
Mac 本机 dsh web 服务的命令行控制面

![License](https://img.shields.io/badge/License-MIT-blue) ![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey) ![Shell](https://img.shields.io/badge/Shell-Bash-green)

一条命令管理 launchd 常驻的 dsh web · 断线自动拉回 · 改端口不用手编 plist

[快速开始](#-快速开始) · [命令](#-命令) · [SKILL.md](SKILL.md)（给 AI agent 的使用指南） · [English](README.en.md)

</div>

---

## ✨ 特性

- **launchd 常驻** —— dsh web 由 LaunchAgent 持有，终端关了、App 退了服务都在，崩溃自动拉回；默认开机自启，`dsh-ctl autostart off` 可关
- **一条命令拿访问地址** —— `dsh-ctl open` 直接用默认浏览器打开带 token 的 URL，不用去日志里翻
- **改端口不用手编 plist** —— `dsh-ctl port 3090` 自动改配置、重启服务、打印新地址
- **一条命令升级** —— `dsh-ctl upgrade` 对比远端最新版，清掉 pnpm 过期元数据缓存（防"假升级"）、预下载验证新版本后再重启，最后回读运行版本确认
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
| `channel` | 查看/切换发布通道（latest / next / 具体版本号） |
| `upgrade` | 升级到当前通道最新版（清 dlx 缓存 + 预下载验证 + 重启 + 校验） |
| `upgrade <版本号>` | 升级/回退到指定版本（plist 通道随之钉住，回滚动通道用 `channel latest`） |
| `autostart` | 开机自启开关（`autostart on/off`，默认 on） |
| `log` | tail -f 服务日志 |
| `start` / `stop` | 启动 / 真停（stop 不会被拉回） |
| `restart` | 重启（kickstart -k） |
| `adopt` | 把宿主手动拉起的进程切到 launchd 接管 |
| `install` | 写入/修复 LaunchAgent plist（幂等） |
| `doctor` | 环境自检：node / 包管理器 / plist / launchd / 端口 / token |

环境变量：`DSH_CTL_PORT` 覆盖端口（默认读 plist，plist 缺省 3080）；`DSH_CTL_LABEL` / `DSH_CTL_LOG` 覆盖 LaunchAgent label 与日志路径（跑隔离实例时用）。

<details>
<summary>dsh-ctl upgrade 具体做了什么（为什么不能只 restart）</summary>

1. 从监听进程读出**当前运行版本**，与 npmjs 官方 registry 的目标版本比较（本机 registry 是镜像时，以官方为准判断有没有新版）
2. 清掉 pnpm 为 `@deepseek-ai/dsh` 缓存的 registry 元数据 —— pnpm dlx 解析 `@latest` 读这份缓存，镜像滞后时 etag 304 会让快照**永不刷新**，直接重启只会"假升级"
3. `pnpm dlx @deepseek-ai/dsh@<目标> --version` 预下载并验证新版本真能跑（失败即中止，**正在运行的服务不受影响**）
4. 重启服务：通道内升级用 `kickstart -k`；指定版本会先改 plist 再 bootout + bootstrap
5. 回读监听进程版本确认真的换成目标版本；没换成会提示多半是镜像还没同步

在 dsh 网页会话内执行 upgrade 时，重启会切断当前会话，命令会改为延时异步重启，并提示重连后用 `dsh-ctl status` 自查。目标版本不比当前新时默认拒绝（防误降级），确要回退用 `dsh-ctl upgrade <版本号> --force`。

</details>

## 📄 License

MIT
