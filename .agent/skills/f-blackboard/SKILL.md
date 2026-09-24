---
name: f-blackboard
description: >-
  File-First Blackboard protocol for multi-agent asynchronous collaboration, Git-worktree
  environment isolation, and on-demand artifact management. Activates ONLY when the user explicitly
  commands file-based archiving, worktree isolation, or loading of specific personalized profiles.
  NEVER pre-read or eagerly load profiles without an explicit user command.
---

# F-Blackboard: 智能体文件黑板与协同规范操作规程 (SOP)

本 Skill 将多 Agent 间的结果复用与个性化管理固化为**确定性、可重复执行的工程操作规程**，消除大模型因概率采样导致的行为漂移。

---

## 核心公理约束（不可动摇的机制底线）

> [!CAUTION]
> **【零主动预读公理 / Strict Inertia】**
> 1. Agent 必须默认保持**完全中立、无偏见的白板状态**。
> 2. **绝对严禁**在会话开始或用户未提及时，主动扫描、预读、加载或假设任何用户的个性化偏好、身份画像或历史偏好文件。
> 3. 只有且仅当用户在对话中给出了**显式指令**（如“读取我的个性化文件”、“加载上次的架构决策”）时，才允许触发寻址与只读加载流程。

---

## 规程一：按需显式读取协议（On-Demand Consumption）

### 触发条件（仅限显式）
用户明确输入：*“读取我的个性化文件”*、*“应用我的XX偏好”*、*“加载上次的决策产物”*。

### 确定性执行步骤
1. **解决发现危机（避免上下文膨胀）**：
   * **严禁**直接将整个 `artifacts/` 或工作区所有 `.md` 文件全文读入上下文。
   * **动作 A**：先查阅轻量目录 `artifacts/INDEX.md`（仅含 URN、分类与一句话摘要）；
   * **动作 B**：若索引未命中或文件被重命名/迁移，运行带外检索脚本定位物理路径：
     ```bash
     bash .agent/scripts/artifact.sh find "<目标关键词或URN>"
     ```
2. **只读挂载与反馈**：
   * 使用文件查看工具只读读取该目标文件的内容；
   * 向用户简要反馈：*“已按指令挂载产物：`[相对路径]`（URN: `...`），作为本次会话的只读约束基准。”*
   * 仅将文件中的参数与结论作为后续推导的只读约束，严禁反向修改该原文件。

---

## 规程二：对话提炼与产物归档（Distill & Archive）

### 触发条件（仅限显式）
用户明确输入：*“归档刚才的讨论”*、*“总结为个性化文件”*、*“将该方案沉淀为架构决策”*。

### 确定性执行步骤
1. **信噪比提炼（过程与结论分离）**：
   * 坚决剔除交互对话中的客套话、试错反问与中间论证；
   * 萃取四大核心要素：
     * **核心结论（Decisions）**
     * **结构化参数（Parameters / Schemas）**
     * **约束与禁忌（Constraints）**
     * **元数据标签（URN, Kind, Tags, Summary）**
2. **规范化落盘**：
   * 参照 `.agent/templates/` 格式，在文件头部写入标准 YAML Frontmatter（必须包含 `urn:`, `kind:`, `title:`, `tags:`, `summary:`, `read_only: true`）；
   * 产物保存至 `artifacts/<kind>s/<slug>.md`；
3. **不可变持久化与索引自愈**：
   * 调用脚本重新构建全景索引并提交 Git：
     ```bash
     bash .agent/scripts/artifact.sh index
     bash .agent/scripts/artifact.sh commit "chore(artifact): archive <kind> [title]"
     ```

---

## 规程三：多 Agent 物理工作区隔离（Worktree Isolation）

### 触发条件
多 Agent 并发作业或需要进行高风险独立实验时。

### 确定性执行步骤
1. **创建隔离物理环境**：
   ```bash
   bash .agent/scripts/worktree.sh create <agent_name>
   ```
2. **在隔离区安全推导**：
   * Agent 在 `.worktrees/<agent_name>` 目录下读写代码与临时数据，主工作区不受任何干扰。
3. **成果交付与合并**：
   * 产物生成并确认后，将分支合并回主产物线：
     ```bash
     bash .agent/scripts/worktree.sh merge <agent_name>
     bash .agent/scripts/worktree.sh remove <agent_name>
     ```

