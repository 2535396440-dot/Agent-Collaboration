# 轻量级 Agent 协作标准

**[简体中文](README.md) | [English](README_EN.md)**

> **一句话概述**：基于纯 Markdown + Git + 操作系统文件系统构建的多智能体异步协同与个性化“黑板”规范。零外部服务依赖，天然防覆写、抗路径变迁，适用于任何本地开发环境与任意 LLM 厂商（Gemini, Claude, OpenAI Codex, Cursor 等）。

> [!NOTE]
> **平台适配声明（Platform Disclaimer）**：  
> 本项目核心基于 **Google Antigravity** 架构与扩展规范（Skills / Rules / Customizations）进行深度设计与优化。  
> 协议底层采用纯文本 Markdown、Git 与 Bash 构建，具有高度通用性；若在其他平台（如 Cursor, Claude Code, OpenAI Codex, Aider 等）中使用，请根据对应平台的指令规范（如 `.cursorrules`, `CLAUDE.md` 等）自行做适当适配与挂载。

---

## 一、核心问题与设计原则

1. **解决多 Agent 结果无法被利用的孤岛问题**：上游 Agent 产出结构化 Markdown 产物，下游 Agent 只读订阅消费，拒绝上下文污染。
2. **彻底解决“文件发现与索引危机”（Discovery Problem）**：
   - 告别在提示词中把几十个文件全量载入的 Token 爆炸灾难；
   - 采用**双层解耦检索**：
     - **第一层（轻量元数据地图）**：`artifacts/INDEX.md` 仅包含表格摘要，平均每项仅 ~20 Tokens；
     - **第二层（带外 Shell 检索）**：当文件海量时，调用 `artifact.sh find "<关键词>"`，由宿主操作系统层完成毫秒级文件匹配，0 上下文消耗，仅返回命中的唯一路径。
3. **消除模型概率性漂移：从提示词上升为 Skill 与状态机**：
   - 编写了官方标准技能文件：`.agent/skills/f-blackboard/SKILL.md`；
   - 在 `AGENTS.md` 中以状态机形式严格编码行为逻辑，确保不同模型行为高度一致。
4. **【零号底线】默认绝对惰性与零主动预读（Strict Inertia）**：
   - Agent **绝对严禁在启动时主动扫描、预读或假设任何个性化偏好/历史文件**；
   - 必须保持完全客观中立的白板状态；
   - 只有且仅当用户在对话中显式给出指令（如：“读取我的个性化文件”）时，才触发按需加载。
5. **纯机制代码，零预设偏好**：
   - 工作区不包含任何预设的用户个人偏好；模板统一收敛在 `.agent/templates/`。

---

## 二、工作区目录结构

```
sumagent/
├── AGENTS.md                  # 【核心入口】面向所有 Agent 的启动契约与状态机固定编码
├── .agent/
│   ├── PROTOCOL.md            # 【详细规范】定义 URN 规范、双层检索、Pub-Sub 协议与隔离流
│   ├── skills/
│   │   └── f-blackboard/      # 【官方技能】符合 Antigravity 规范的确定性操作规程 (SOP)
│   │       └── SKILL.md
│   ├── templates/             # 【空白模板】纯机制的空白产物规范模板 (不含个人偏好)
│   │   ├── profile.template.md
│   │   └── decision.template.md
│   └── scripts/               # 【零依赖辅助工具】纯 Bash + Git 脚本
│       ├── artifact.sh        # 动态索引生成、带外语义嗅探、原子提交
│       └── worktree.sh        # Agent 物理隔离工作区（Git Worktree）创建与合并
├── artifacts/                 # 【黑板产物池】空状态纯净黑板池
│   ├── INDEX.md               # 动态全景元数据地图 (当前收录 0 项，等待用户指令生成)
│   ├── profiles/              # 个性化文件池（仅保留 .gitkeep）
│   └── decisions/             # 决策与阶段产物池（仅保留 .gitkeep）
├── try.md                     # 前期开源项目调研与可行性评估报告
├── README.md                  # 中文使用说明
└── README_EN.md               # English Documentation
```

---

## 三、使用说明与命令速查

### 1. 新工作区 10 秒极速植入
将 `AGENTS.md` 和 `.agent/` 复制到任何新代码库根目录，执行 `git init` 即可。

### 2. 用户对话交互示范
* **日常对话（默认状态）**：直接提问编码任务 $\rightarrow$ Agent 保持完全客观中立，绝不加载任何个性化偏好。
* **显式调用个性化**：用户输入 *“读取我的个性化文件”* 或 *“参考某某架构决策”* $\rightarrow$ Agent 激活技能规程一，带外检索并只读挂载目标文件。
* **显式归档**：用户输入 *“把刚才讨论的方案归档为决策产物”* $\rightarrow$ Agent 激活技能规程二，剔除口水话生成标准 Markdown 并提交 Git。

### 3. 辅助脚本命令
```bash
# 扫描工作区并重建轻量元数据索引 (INDEX.md)
bash .agent/scripts/artifact.sh index

# 带外语义嗅探 (0 Token 消耗秒级定位文件)
bash .agent/scripts/artifact.sh find "<关键词或URN>"

# 原子持久化到 Git
bash .agent/scripts/artifact.sh commit "chore(artifact): archive ..."

# 为 Agent 创建物理隔离工作区
bash .agent/scripts/worktree.sh create <agent_name>
```
