# 切换手册

> 如何在 PI-Desktop 里手动切换 智能体角色 / Skill / MCP
> 生成依据：元宝会话导出（792 会话 / 7905 消息）的分析结果

---

## 一、目录结构

```
~/.pi/agent/                          ← Agent 规则与角色
├── AGENTS.md                          通用流程与安全规范（原有，229 行）
├── agent.md                           本机实操规则（新增）
├── soul.md                            行为内核：判断与语气（新增）
├── SWITCHING.md                       本文件
├── mcp-recommendations.md             MCP 配置说明（新增）
├── prompt.d/                          ← 系统提示注入，每个 .md 都会被加载
│   ├── cn.star.skill-learning.md      技能学习规范（原有）
│   ├── role.ops-triage.md             角色：运维排障（新增）
│   ├── role.scripting.md              角色：脚本开发（新增）
│   └── role.ai-toolchain.md           角色：AI 工具链（新增）
└── user-profile/
    ├── USER.md                        用户画像（已重写，保留原有信息）
    └── MEMORY.md                      环境踩坑记忆（原有，未改动）
```

PI 实际加载的技能与 MCP 配置不在 `.pi` 下，而在用户主目录的 `.agents` 目录中：
技能放在其 `skills` 子目录，MCP 配置放在其 `servers` 子目录。

---

## 二、切换智能体角色

角色由 `~/.pi/agent/prompt.d/` 下的 `.md` 文件驱动，该目录每个文件都会被注入系统提示。

### 现有三个角色

| 角色 | 文件 | 适用场景 |
|---|---|---|
| 运维排障 ops-triage | `prompt.d/role.ops-triage.md` | 网络/系统/硬件故障、要具体命令 |
| 脚本开发 scripting | `prompt.d/role.scripting.md` | 写脚本、改代码、批处理 |
| AI 工具链 ai-toolchain | `prompt.d/role.ai-toolchain.md` | 配 API、跑本地模型、接 MCP |

### 如何切换

**方法 A：只留一个角色（推荐，最干净）**

把不想用的角色文件改名，加 `.off` 后缀即可停用：

```powershell
# 只保留运维排障角色
Rename-Item "$env:USERPROFILE\.pi\agent\prompt.d\role.scripting.md" "role.scripting.md.off"
Rename-Item "$env:USERPROFILE\.pi\agent\prompt.d\role.ai-toolchain.md" "role.ai-toolchain.md.off"

# 恢复
Rename-Item "$env:USERPROFILE\.pi\agent\prompt.d\role.scripting.md.off" "role.scripting.md"
```

切换后需要重启 PI-Desktop 或新开会话才生效，因为系统提示在会话开始时组装。

**方法 B：全部启用**

三个角色同时存在时，它们在系统提示里共存。适合什么活都干的日常会话，但角色特征会被稀释。

### 建议

- 专注排障时：只留 ops-triage
- 写脚本时：只留 scripting
- 折腾 AI 配置时：只留 ai-toolchain
- 日常混合使用：三个全开，或全关，只靠 `agent.md` 与 `soul.md`

---

## 三、切换 Skill

Skill 由模型按 description 自动判断是否加载，不需要手动开关，但可以控制可用性。

### 查看已加载

PI-Desktop 的 设置 到 Skills 页面，能看到技能目录下的全部条目。

### 停用某个 skill

把技能目录下的子目录改名加 `.off` 后缀即可停用，去掉后缀即恢复。

```powershell
$sk = Join-Path $env:USERPROFILE ".agents" | Join-Path -ChildPath "skills"

# 停用
Rename-Item (Join-Path $sk "network-triage-cn") "network-triage-cn.off"

# 恢复
Rename-Item (Join-Path $sk "network-triage-cn.off") "network-triage-cn"
```

### 四个 skill 的触发条件

| Skill | 什么时候会触发 |
|---|---|
| network-triage-cn | 说打不开、跳转、解析不对、连不上、证书报错 |
| windows-desktop-triage-cn | 说蓝屏、开不了机、电脑卡、驱动失败 |
| ai-api-relay-triage-cn | 说 API 报错、503、额度、模型不存在、Ollama |
| browser-session-data-export | 说导出或抓取需要登录的数据 |

### 强制使用某个 skill

直接说：用 network-triage-cn 排查这个问题，即可。

---

## 四、切换 MCP

MCP 配置在主目录 `.agents` 下的 `servers` 子目录，每个 JSON 一个 server。

### 在 PI 里管理

设置 到 MCP 服务器，可以逐个启用或禁用，无需改文件。

### 用文件控制

```powershell
$sv = Join-Path $env:USERPROFILE ".agents" | Join-Path -ChildPath "servers"

# 停用
Rename-Item (Join-Path $sv "memory.json") "memory.json.off"

# 恢复
Rename-Item (Join-Path $sv "memory.json.off") "memory.json"
```

### 当前状态

| Server | 状态 | 备注 |
|---|---|---|
| everything | 可用 | 测试用，可随时删 |
| filesystem | 可用 | 已限定 5 个目录 |
| memory | 可用 | 长期记忆 |
| sequential-thinking | 可用 | 多步推理，排障时有用 |
| github | 待处理 | 含明文 token |
| time | 不可用 | uvx 未安装，启动必失败 |

详细说明见 `mcp-recommendations.md` 第三节。

---

## 五、快速切换脚本

已生成 `~/.pi/switch-role.ps1`。

用法：

```powershell
& "$env:USERPROFILE\.pi\switch-role.ps1" ops      # 只开运维排障
& "$env:USERPROFILE\.pi\switch-role.ps1" script   # 只开脚本开发
& "$env:USERPROFILE\.pi\switch-role.ps1" ai       # 只开 AI 工具链
& "$env:USERPROFILE\.pi\switch-role.ps1" all      # 全开
& "$env:USERPROFILE\.pi\switch-role.ps1" none     # 全关
```

切换后重启 PI-Desktop 或新开会话。

---

## 六、各层配置的职责

| 层 | 管什么 | 改它的频率 |
|---|---|---|
| AGENTS.md / agent.md | 流程、安全、本机规则 | 偶尔 |
| soul.md | 判断方式与语气 | 很少 |
| USER.md / MEMORY.md | 你是谁、这台机器的坑 | 持续积累 |
| prompt.d/role.*.md | 当前扮演什么角色 | 经常切换 |
| 技能目录 | 特定领域的操作手册 | 按需增加 |
| servers 目录 | 外部工具接入 | 按需增删 |

切换角色只动 `prompt.d/`，不要动其他层。
