# F-Blackboard: 基于文件系统与 Markdown 的多 Agent 协作与个性化 IO 标准

> **核心哲学**：
> 1. **产物即契约（Artifact as Contract）**：交互过程可以丰富发散，但交付沉淀必须是高信噪比的 Markdown 结构化产物。
> 2. **文件即黑板（Filesystem as Blackboard）**：文件系统是天然的通用总线，解耦 Agent 运行时、模型厂商与生命周期。
> 3. **只读即防腐（Read-Only as Guardrail）**：上游产物对下游是只读事实，下游基于输入推理派生，不可覆写篡改。
> 4. **语义寻址免绝对路径（Semantic Over Absolute Path）**：通过 YAML Frontmatter 唯一标识与语义标签定位，抗用户重命名与路径迁移。

---

## 1. 个性化产物契约规范（YAML Frontmatter Schema）

工作区内的每一个“个性化文件”、“记忆文件”或“阶段结论产物”，都必须在 Markdown 文件头部包含如下标准 YAML Frontmatter 元数据块：

```yaml
---
urn: "urn:agent:profile:user-preference" # 全局或工作区唯一语义 URN
kind: "profile"                          # 类型: profile(个性化偏好) | memory(长期记忆) | decision(架构决策) | deliverable(阶段产物)
title: "开发者全局编码偏好与协作规范"
tags: ["preference", "python", "clean-code", "style"]
summary: "定义了用户在代码生成、架构选型及与 AI 对话时的硬性偏好与风格指南"
read_only: true                          # 标记下游 Agent 是否应以只读模式消费
version: "1.0.0"                         # 语义化版本号
producer: "human-and-agent"              # 产出者身份
updated_at: "2026-09-24T12:00:00"
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

## 2. Agent 寻址与读取协议（Sub - Read-Only Consumption）

当用户在对话中提到：
> *“读取我的个性化文件”*  
> *“参考我之前的架构决策”*  
> *“按照我的编码风格来写”*  

### Agent 的标准执行流程（语义嗅探模式）
1. **禁止行为**：
   * ❌ 禁止直接在代码或 Prompt 中写死绝对路径（如 `C:/Users/xxx/file.md` 或 `/root/project/docs/style.md`）。
   * ❌ 禁止因找不到字面同名文件就直接报错放弃。
2. **正确执行步骤**：
   * **步骤 A（查阅索引）**：优先检查工作区是否存在 `artifacts/INDEX.md`。如有，检索匹配的 `urn` 或 `summary`。
   * **步骤 B（语义与元数据嗅探）**：若无索引或文件被移动，执行轻量扫描：
     ```bash
     git grep -l "kind: profile"
     # 或针对语义标签进行嗅探
     git grep -l "urn:agent:profile"
     ```
   * **步骤 C（只读加载与确认）**：
     * 读取对应文件的 Markdown 内容。
     * 向用户快速确认一句：*“已根据标签 [xxx] 挂载个性化配置文件 [文件路径] 作为只读基准，开始执行下一步……”*
   * **步骤 D（防腐遵循）**：
     * 将文件中的决策项作为本轮对话的**公理约束（Ground Truth）**，不得在后续推导中违背该文件中声明的原则。

---

## 3. 对话总结与归档协议（Pub - Archive & Distillation）

当用户下达总结性、归档性指令时，例如：
> *“总结我们刚才的讨论，生成个性化偏好文件”*  
> *“把刚才定下来的接口规范归档”*  
> *“把这段对话的结论保存为一个新的阶段产物”*  

### Agent 的标准执行流程
1. **过程与产物剥离（Distillation）**：
   * 剔除所有寒暄、试错过程、反问和多余解释。
   * 萃取最具价值的：
     * **核心决策列表（Decisions）**
     * **参数/常量/数据结构（Parameters & Schemas）**
     * **约束与禁忌（Constraints & Anti-patterns）**
2. **生成标准 Markdown 产物**：
   * 在文件头部按规范注入完整的 YAML Frontmatter。
   * 推荐存储在 `artifacts/<kind>s/` 目录下（如 `artifacts/profiles/` 或 `artifacts/decisions/`），以可读的短横线命名法（slug）命名（如 `user-coding-style.md`）。
3. **版本化提交与不可变保障（Git Commit）**：
   * 生成文件后，Agent 调用 Git 执行原子提交，形成不可篡改的历史记录：
     ```bash
     git add <file_path>
     git commit -m "chore(artifact): archive <kind> [title] - version [ver]"
     ```
4. **动态维护索引**：
   * 触发更新 `artifacts/INDEX.md`，使工作区始终保持一张自解释的产物全局地图。

---

## 4. Git Worktree 物理隔离协议（Multi-Agent Workspace Isolation）

当存在多个 Agent（例如 Agent-Gemini 负责架构分析，Agent-Codex 负责编写代码测试）同时在一个代码库上工作时，为避免文件锁冲突与环境脏写，采用 Git Worktree 进行物理隔离：

```
主仓库目录（Main Workspace: master 分支）
  ├── .git/
  ├── .agent/            <-- 全局共享 IO 标准与工具
  ├── artifacts/         <-- 统一产物交付与索引池
  └── .worktrees/        <-- 隔离的 Agent 子工作区（不纳入版本控制）
       ├── agent-gemini/ <-- 挂载至分支 agent/gemini
       └── agent-codex/  <-- 挂载至分支 agent/codex
```

### 协作流转规范
1. **创建独立环境**：
   ```bash
   git worktree add -b agent/gemini .worktrees/agent-gemini master
   ```
2. **独立推导与产出**：
   * Agent-Gemini 在 `.worktrees/agent-gemini` 内部执行所有中间操作、生成临时测试文件。
3. **成果交付（发布到主线）**：
   * Agent-Gemini 将提炼出的产物提交到 `agent/gemini` 分支。
   * 通过将产物合并或检出到主分支的 `artifacts/` 目录，使下游 Agent-Codex 能够以只读方式检视该成果。
4. **清理释放**：
   * 任务完成后，执行 `git worktree remove .worktrees/agent-gemini` 释放磁盘空间。

---

## 5. 极简性与未来模型前向兼容声明

本标准之所以**坚决拒绝引入 Python/Node.js 运行时或复杂的向量数据库**，是因为：
1. **未来的大模型具备极强的自然语言自省能力**：现代与未来 LLM 擅长阅读 YAML 元数据、理解 Markdown 语义，以及通过轻量 Shell 命令自寻路径。
2. **零安装负担**：只要目标主机安装了 Git 和任意文本编辑器，本标准在任何工作区均可 1 秒内激活，永不过期、永不发生依赖破坏。
