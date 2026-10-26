# MCP 配置说明

> 位置：`C:\Users\sitxiaochen\.agents\servers\*.json`
> 每个 JSON 一个 server，PI-Desktop 从该目录加载。
> 最后更新：2026-10-23

---

## 一、当前已配置（6 个）

| ID | 传输 | 状态 | 说明 |
|---|---|---|---|
| `everything` | stdio / npx | ✅ 可用 | 官方测试服务器，含 echo/sum 等工具 |
| `filesystem` | stdio / npx | ✅ 可用 | **已限定目录**，见下方变更 |
| `github` | http | ⚠️ 含明文 token | 远程官方 MCP |
| `memory` | stdio / npx | ✅ 可用 | 知识图谱式长期记忆 |
| `sequential-thinking` | stdio / npx | ✅ 可用 | 多步推理，适合排障 |
| `time` | stdio / **uvx** | ❌ 不可用 | **uvx 未安装**，见下方问题 |

---

## 二、本次变更

### ✅ `filesystem` — 收紧了权限范围

**变更前**：`args: ["-y", "@modelcontextprotocol/server-filesystem", "."]`
挂载当前工作目录。问题是工作目录随项目变化，实际等于"能碰任何打开过的项目目录"，边界不清晰。

**变更后**：显式挂载 5 个固定目录
- `Desktop`（含元宝导出等产物）
- `Documents`
- `Downloads`
- `.pi\agent`（Agent 配置与画像）
- `.agents`（skills 与 servers 配置）

**收益**：范围明确、可预期；避免误写系统目录或其他项目。

**如需增减目录**：直接编辑 `filesystem.json` 的 `args` 数组，末尾追加路径即可。

---

## 三、待你处理的两个问题

### ⚠️ 问题 1：`github.json` 含明文 PAT

当前文件里 `headers.Authorization` 是一串**明文 GitHub 个人访问令牌**（`github_pat_11AQ6...`）。

**风险**：
- 以明文存在磁盘上，任何能读该文件的进程都能拿到
- 若该目录被同步/备份/误传，token 即泄露
- 从 token 前缀看是 fine-grained PAT，权限范围需你自行确认

**建议处理**（三选一）：
1. **改用环境变量引用**（推荐）：把 token 移到系统环境变量，配置里写 `${env:GITHUB_PAT}`
2. **收窄权限**：到 GitHub 设置里确认该 PAT 只有必要 scope（如仅 repo 读）
3. **吊销重建**：若曾外泄，立即吊销并重建

**我没有直接改这个文件**，因为不清楚 PI-Desktop 是否支持 `${env:}` 插值。你若确认支持，我可以改。

### ❌ 问题 2：`time` 依赖的 `uvx` 不存在

`time.json` 用 `uvx mcp-server-time` 启动，但本机：
- `uvx` 未安装（`Get-Command uvx` 为空）
- npm 上没有对应的 Node 版替代包（`@modelcontextprotocol/server-time` 返回 404）

**结论**：这个 server 现在启动必然失败。

**处理方式**（二选一）：
1. **安装 uv**：`winget install astral-sh.uv` 或 `pipx install uv`（需先解决 Python 问题）
2. **删除该配置**：时间换算用 PowerShell `[TimeZoneInfo]::ConvertTime` 即可，不必走 MCP

---

## 四、推荐补充的两个 server

### `fetch` — 抓取官方文档与实时信息

**为什么需要**：你的高频需求里有一类是**时效性信息**——硬件报价、软件最新版本、政策公告。模型训练数据有截止日期，`fetch` 能拿到实时页面。

**安装**（需要 uvx，与上述问题 2 同源）：

```json
{
  "id": "fetch",
  "label": "Fetch",
  "description": "抓取网页并转为 Markdown，用于查官方文档、版本、价格",
  "transport": "stdio",
  "command": "uvx",
  "args": ["mcp-server-fetch"],
  "env": {},
  "url": null,
  "headers": {}
}
```

**若不想装 uv**：跳过。需要实时信息时我可以用 CDP 方案直接访问。

### `sqlite` — 处理结构化日志与清单

**为什么需要**：运维场景常有资产清单、事件日志这类结构化数据。你的会话里 SQL 相关提问不少。

**注意**：本机无 SQLite CLI，需通过 npm 包提供。是否配置取决于你实际有没有这类数据要处理——**没有就先不装**。

---

## 五、不建议配置的

| MCP | 不推荐原因 |
|---|---|
| `brave-search` 等搜索类 | 需 API Key 且免费额度低，`fetch` 更省 |
| `puppeteer` / `playwright` | 你已有 CDP 方案（见 `browser-session-data-export` skill），两套并存反而复杂 |
| `docker` | 本机未安装 Docker |
| `postgres` / `mysql` | 无明确生产库运维需求 |
| SaaS 集成（Slack/Notion 等） | 会话中未见使用场景 |

---

## 六、安全原则

1. **最小权限**：`filesystem` 只挂必要目录，绝不挂 `C:\` 或用户根目录
2. **凭据不落盘明文**：API Key / token 用环境变量引用
3. **本地优先**：能本地跑的不走云服务
4. **按需启用**：不用的删掉，减少攻击面与上下文占用
5. **第三方 MCP 先审源码**：MCP 能读写文件、执行命令，权限很大
