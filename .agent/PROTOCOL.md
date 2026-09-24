# F-Blackboard: 基于文件系统与 Markdown 的多 Agent 协作与个性化 IO 标准

> **核心哲学**：
> 1. **产物即契约（Artifact as Contract）**：交互过程可以丰富发散，但交付沉淀必须是高信噪比的 Markdown 结构化产物。
> 2. **文件即黑板（Filesystem as Blackboard）**：文件系统是天然的通用总线，解耦 Agent 运行时、模型厂商与生命周期。
> 3. **只读即防腐（Read-Only as Guardrail）**：上游产物对下游是只读事实，下游基于输入推理派生，不可覆写篡改。
> 4. **语义寻址免绝对路径（Semantic Over Absolute Path）**：通过 YAML Frontmatter 唯一标识与语义标签定位，抗用户重命名与路径迁移。
> 5. **默认惰性与零预读（Strict Inertia）**：模型仅知晓协议规程，严禁未经显式指令提前加载或预设任何个性化偏好。

---

## 1. 个性化产物契约规范（YAML Frontmatter Schema）

工作区内的每一个“个性化文件”、“记忆文件”或“阶段结论产物”，都必须在 Markdown 文件头部包含如下标准 YAML Frontmatter 元数据块：

```yaml
---
urn: "urn:agent:profile:{{SLUG}}"       # 全局或工作区唯一语义 URN
kind: "profile"                          # 类型: profile(个性化偏好) | memory(长期记忆) | decision(架构决策) | deliverable(阶段产物)
title: "{{TITLE}}"
tags: ["{{TAG_1}}", "{{TAG_2}}"]
summary: "{{ONE_SENTENCE_SUMMARY}}"
read_only: true                          # 标记下游 Agent 是否应以只读模式消费
version: "1.0.0"                         # 语义化版本号
producer: "{{AGENT_OR_HUMAN_ID}}"        # 产出者身份
updated_at: "{{ISO_TIMESTAMP}}"
---
```

### 字段释义与规则
| 字段 | 必填 | 说明 | 作用 |
| :--- | :--- | :--- | :--- |
| `urn` | 是 | 唯一语义资源名，格式建议 `urn:agent:<kind>:<name>` | **防路径断裂核心**：无论文件在何处，通过 URN 即可全局唯一锁定 |
| `kind` | 是 | 资源类别：`profile` / `memory` / `decision` / `deliverable` | 便于 Agent 快速按类别过滤 |
| `title` | 是 | 产物的人类可读标题 | 展示与语义对照 |
| `tags` | 是 | 语义标签数组（如 `["auth", "jwt", "backend"]`） | **模糊匹配核心**：用户自然语言表述时用于意图命中 |
| `summary` | 是 | 1~2 句话总结其核心内容 | Agent 在构建全景地图时只需阅读 summary，无需加载全文 |
| `read_only`| 否 | 布尔值，默认 `true` | 指引下游 Agent 仅能读取、不可擅自覆写 |
| `version` | 否 | 语义化版本，如 `1.0.0` | 配合 Git 支持版本追溯与演进 |

---

## 2. 彻底解决“文件发现与索引危机”（Discovery Problem 治理）

在多 Agent 长周期工作中，文件可能累积几十上百个。若盲目全量加载，将瞬间造成上下文爆炸与 Token 浪费。本标准采用**双层解耦架构**彻底解决发现危机：

```
用户指令: "读取我的鉴权决策"
            │
            ▼
    ┌───────────────────────┐
    │ 途径 A: 查阅 INDEX.md │ <─── 仅阅读轻量表格元数据 (平均每项 ~20 Tokens)
    └───────────────────────┘
            │
       (若未命中/改名)
            ▼
    ┌───────────────────────┐
    │ 途径 B: 带外脚本检索  │ <─── 运行 bash .agent/scripts/artifact.sh find "auth"
    └───────────────────────┘      (在宿主操作系统层完成 grep，0 上下文消耗)
            │
            ▼
    定位唯一目标文件: artifacts/decisions/auth.md
            │
            ▼
    仅只读加载该单个目标文件 (O(1) 精准注入上下文)
```

1. **第一道防线：轻量全景索引（`artifacts/INDEX.md`）**
   - 索引只包含 URN、类别、标题、标签与一句话摘要。即便有 100 个产物文件，全表仅约 2000 Tokens，Agent 一瞥即知所需目标，无需遍历文件内容。
2. **第二道防线：带外 Shell 检索（`artifact.sh find`）**
   - 当文件量级极大（成千上万）或用户把文件任意移动改名时，Agent 无需将任何索引载入上下文，而是通过调用命令行工具在宿主操作系统层执行 grep 嗅探。检索耗费的是操作系统的毫秒级计算，输入给模型的仅为最终命中的 1 个相对路径。
3. **第三道防线：禁止批量读取准则**
   - 契约严格规定：严禁 Agent 批量加载多个 `.md` 产物。任何操作只对准经前置索引命中的单一目标文件。

---

## 3. Agent 寻址与读取协议（Sub - Read-Only Consumption）

> [!IMPORTANT]
> **默认中立原则**：Agent 在启动时绝不主动预读任何个性化文件。只有在用户发出显式调用指令时方可触发以下步骤。

### 显式触发后的标准执行流程：
1. **定向检索**：通过 `artifacts/INDEX.md` 或 `bash .agent/scripts/artifact.sh find "<目标>"` 定位目标。
2. **只读挂载与反馈**：
   - 仅只读读取命中的该单个 Markdown 文件；
   - 向用户明确确认：*“已根据指令挂载产物：`[文件路径]`，作为后续执行的只读约束基准。”*
3. **防腐遵循**：
   - 将文件中的决策项作为本轮对话的**公理约束（Ground Truth）**，不得违背该文件中声明的原则。

---

## 4. 对话总结与归档协议（Pub - Archive & Distillation）

当用户下达总结性、归档性指令时：
1. **过程与产物剥离（Distillation）**：
   - 剔除所有寒暄、试错过程、反问和多余解释；
   - 萃取核心决策（Decisions）、结构化参数（Schemas）、约束与禁忌（Constraints）。
2. **生成标准 Markdown 产物**：
   - 在文件头部注入标准 YAML Frontmatter；
   - 存入 `artifacts/<kind>s/` 目录下。
3. **版本化提交与不可变保障（Git Commit）**：
   - 执行脚本重建索引并原子提交到 Git 仓库：
     ```bash
     bash .agent/scripts/artifact.sh index
     bash .agent/scripts/artifact.sh commit "chore(artifact): archive <kind> [title]"
     ```

---

## 5. Git Worktree 物理隔离协议（Multi-Agent Workspace Isolation）

多 Agent 并发作业时，使用 Git Worktree 进行物理隔离：
```bash
# 1. 创建隔离物理工作区
bash .agent/scripts/worktree.sh create <agent_name>

# 2. Agent 在 .worktrees/<agent_name> 下独立推导，主分支不受影响

# 3. 成果交付与清理
bash .agent/scripts/worktree.sh merge <agent_name>
bash .agent/scripts/worktree.sh remove <agent_name>
```
