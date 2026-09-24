---
name: dsh-ctl
description: Mac 本机 dsh web 服务的统一控制面。当用户要求重启/停止/升级 dsh、dsh web 打不开、取访问 URL 或 token、改端口、切换 latest/next 通道、或排查 dsh 服务问题时使用。进程归 LaunchAgent cn.${USER}.dsh-web 持有，禁止直接 kill。
---

# dsh-ctl — agent 操作指南

## 进程模型（先读懂再操作）

dsh web 不是普通前台进程，由 **LaunchAgent `cn.${USER}.dsh-web`** 持有（launchd 直接子进程，PPID=1）。含义：

- 终端退出、agent 会话结束、浏览器关掉，服务都**不会**停
- 崩溃/唤醒异常会被 launchd 自动拉回（KeepAlive）
- **禁止直接 `kill` 监听进程**——launchd 会立即重启它，还可能打乱 KeepAlive 语义。一切操作走 `dsh-ctl`

进程链正常形态：`launchd → pnpm dlx → node（实际监听）`，监听进程是孙进程，判断归属要沿父链向上找。

## 环境速查

- 脚本位置：`~/.local/bin/dsh-ctl`（软链，真相源在仓库）
- plist：`~/Library/LaunchAgents/cn.${USER}.dsh-web.plist`（**端口/通道/自启的唯一真相源**）
- 日志：`~/Library/Logs/dsh-web.log`
- 默认端口 3080，以 plist 为准（`dsh-ctl port` 查看）

## 命令速查

| 场景 | 命令 |
|------|------|
| 服务出问题，先体检 | `dsh-ctl doctor`（六项自检，有 FAIL 时 exit 1） |
| 看整体状态 | `dsh-ctl status`（launchd + 端口 + 通道 + 版本 + 归属链） |
| 取访问地址 | `dsh-ctl url`（带 token 的完整 URL） |
| 用浏览器打开 | `dsh-ctl open` |
| 看实时日志 | `dsh-ctl log` |
| 启动 / 真停 / 重启 | `dsh-ctl start` / `stop` / `restart` |
| 改端口 | `dsh-ctl port 3080`（改 plist + 重载 + 打印新 URL） |
| 切发布通道 | `dsh-ctl channel next`（或 latest / 具体版本号） |
| 开机自启 | `dsh-ctl autostart on/off`（默认 on） |
| 修复/重写 plist | `dsh-ctl install`（幂等） |
| 手动进程迁到 launchd | `dsh-ctl adopt`（交互确认） |

## 典型工作流

**用户说 dsh 打不开/挂了：**
1. `dsh-ctl doctor` → 按 FAIL 项修
2. `dsh-ctl status` → 看端口监听、归属链、版本
3. 无监听 → `dsh-ctl start`；有监听但异常 → `dsh-ctl restart`
4. 还不行 → `dsh-ctl log` 看日志报错

**用户要升级/换 next 通道尝鲜：**
`dsh-ctl channel next`（写 plist 前会向 npm 校验通道存在；首次拉新版本依赖冷启动可达 1 分钟，命令内置等待窗口，提示"尚未监听"不代表失败，等十几秒再 `status`）

**用户要在别处打开 dsh：**
`dsh-ctl url` 拿带 token 的地址给用户（token 每次重启都变，别缓存旧 URL）

## 关键坑点

- **token 只在日志里**：服务启动时随机生成、只打到 stdout（被 launchd 收进日志）。`url` 命令就是从日志 tail 最新一条。日志被清则取不到，重启服务即重新生成
- **改 plist 不等于生效**：`restart`（kickstart -k）**不重读** plist；`port`/`channel`/`autostart` 命令内部已做 bootout+bootstrap 重载，别手动改 plist 后只 restart
- **别凭记忆写端口**：端口真相源是 plist，先 `dsh-ctl port` 读当前值
- **`channel -h` 之类参数**：`-` 开头参数会被当帮助处理，不会写进 plist；切通道前有 npm dist-tags 校验，不存在的通道直接拒绝
- **服务未加载时**：`stop`/`restart` 会报错提示先 `install && start`，属正常防护
