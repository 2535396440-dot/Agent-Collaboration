# AGENTS.md - 工作区多智能体协同协议与状态机契约

> **致所有进入本工作区的 AI 智能体（Gemini, Claude, Codex, Cursor 等）**：
> 本工作区遵循 **`F-Blackboard`（文件驱动黑板与轻量产物 Pub-Sub 协议）**，并挂载同名技能规范。
> 为杜绝不同模型的概率性语义理解偏差，所有进入本工作区的智能体必须严格遵循以下**状态机与固定行为编码**：

---

## 零号底线原则：默认惰性与禁止预读（Strict Inertia）

```
[ 会话启动默认状态: INERT (完全白板 / 绝对中立) ]
       │
       ├── (用户普通对话) ───────────────> 正常就事论事，保持标准通用助手响应
       │
       ├── (用户显式指令: "读取个性化...") ──> 触发 [规程一: 按需只读挂载]
       │
       ├── (用户显式指令: "归档/总结...") ──> 触发 [规程二: 结构化提炼落盘]
       │
       └── (用户显式指令: "多Agent隔离") ─> 触发 [规程三: Git Worktree 隔离]
```

> [!CAUTION]
> **绝对禁令**：
> 1. **严禁在会话开始或用户未显式要求时，主动检索、预先读取或盲目假设任何用户的个性化偏好、行为画像或历史意图。**
> 2. 用户可能在某些任务中需要纯粹、中立的客观推理。未经对话显式授权，不得让任何历史“个性化”内容污染当前任务上下文。

---

## 固定行为编码规范（State Machine Actions）

### 状态 1：按需显式读取（On-Demand Consumption）
* **仅当**用户输入包含 *“读取我的个性化文件”*、*“应用我的XX偏好”* 或 *“参考上次的XX决策”* 时触发。
* **执行逻辑（彻底解决发现危机）**：
  1. **禁止批量加载**：严禁遍历读取工作区或 `artifacts/` 目录下的所有 `.md` 文件全文；
  2. **带外秒级检索**：优先查阅 `artifacts/INDEX.md`（仅含元数据索引），或通过命令行调用 `.agent/scripts/artifact.sh find "<关键词>"`；
  3. **只读挂载**：根据检索到的相对路径只读加载**且仅加载该单个文件**，将提取出的参数作为本会话不可变的只读约束。

### 状态 2：对话提炼与产物归档（Distill & Archive）
* **仅当**用户下达总结性、归档性指令（如 *“总结并归档为产物”*、*“沉淀为架构决策”*）时触发。
* **执行逻辑**：
  1. 剔除所有沟通口水话，提炼出核心结论、数据参数、约束清单；
  2. 按照 `.agent/templates/` 规范注入标准 YAML Frontmatter（包含 `urn:`, `kind:`, `tags:`, `summary:`）；
  3. 写入 `artifacts/<kind>s/`，并执行 `bash .agent/scripts/artifact.sh index` 与 `commit` 固化版本。

### 状态 3：物理环境隔离（Worktree Isolation）
* **仅当**进行多 Agent 并发作业或高风险独立实验时触发。
* **执行逻辑**：使用 `bash .agent/scripts/worktree.sh create <agent_name>` 在独立的 `.worktrees/<agent_name>` 下作业，通过分支合并完成交接。

---

## 协议与技能映射
* 详细技术标准详见：[.agent/PROTOCOL.md](file:///.agent/PROTOCOL.md)
* 格式化技能规程详见：[.agent/skills/f-blackboard/SKILL.md](file:///.agent/skills/f-blackboard/SKILL.md)
* 动态产物目录清单：[artifacts/INDEX.md](file:///artifacts/INDEX.md)
