# F-Blackboard: 零依赖轻量级 Agent IO 协议与个性化协同标准

> **一句话概述**：基于纯 Markdown + Git + 操作系统文件系统构建的多智能体异步协同与个性化“黑板”规范。零外部服务依赖，天然防覆写、抗路径变迁，适用于任何本地开发环境与任意 LLM 厂商（Gemini, Claude, OpenAI Codex, Cursor 等）。

---

## 一、为什么设计这个标准？

1. **解决多 Agent 结果无法被利用的孤岛问题**：上游 Agent 产出结构化 Markdown 产物，下游 Agent 只读订阅消费，拒绝上下文污染。
2. **解决个性化文件“一改名/移路径就失效”的脆弱性**：引入语义 URN 与标签机制，用户在电脑上随意移动、重命名个性化文件，Agent 通过语义嗅探依然能够 100% 自动对齐。
3. **解决多 Agent 并发写冲突**：利用 `git worktree` 物理隔离各 Agent 的作业目录，利用 Git Commit 实现成果的不可变追溯与版本审计。
4. **轻量与前向兼容**：未来的大模型越来越聪明，不需要笨重的向量数据库或复杂的 Python 常驻服务，只需一套自解释的文档标准与轻量脚本即可跑通。

---

## 二、目录结构一览

```
sumagent/
├── AGENTS.md                  # 【核心入口】任何 Agent 进入工作区首先读取的全局指导契约
├── .agent/
│   ├── PROTOCOL.md            # 【详细规范】定义 URN 规范、Pub-Sub 协议、归档标准与隔离流
│   └── scripts/               # 【零依赖辅助工具】纯 Bash + Git 脚本
│       ├── artifact.sh        # 动态索引生成、语义嗅探检索、原子提交
│       └── worktree.sh        # Agent 物理隔离工作区（Git Worktree）创建与合并
├── artifacts/                 # 【黑板产物池】个性化文件与产物默认存放区
│   ├── INDEX.md               # 产物全景动态地图（支持随时重建）
│   ├── profiles/              # 个性化服务与偏好文件池
│   │   └── developer-preference.md
│   └── decisions/             # 架构决策与阶段性产物
│       └── ad-001-multi-agent-file-bus.md
├── try.md                     # 前期开源项目调研与可行性评估报告
└── README.md                  # 本文档
```

---

## 三、你以后在任意新工作区的使用流程

### 步骤 1：新工作区一键植入（10 秒极速启动）
在电脑任何地方新建一个项目文件夹，只需将本工作区的两个核心要素复制过去：
1. `AGENTS.md`
2. `.agent/` 目录

*(如有 Git 仓库，执行 `git init` 即可享受完整的不可变版本保障。)*

### 步骤 2：全局预设定（Antigravity / Codex / Cursor / Claude Code）
在 IDE 的全局系统提示词（Custom Instructions / System Prompt）中添加如下简短说明：
```text
【工作区自省规则】
当你进入任何工作区时，请优先检查工程根目录下是否存在 AGENTS.md 或 .agent/PROTOCOL.md。
若存在，请严格遵循 F-Blackboard 规范：
1. 用户提到“读取个性化配置/我的偏好/架构决策”时，主动通过语义嗅探（URN/标签）寻找对应的 Markdown 产物，以只读模式载入；
2. 用户要求“总结/归档/沉淀”时，将结论剥离口水话后生成带标准 YAML Frontmatter 的 Markdown 产物并建议 Git 提交；
3. 多 Agent 场景下使用 Git Worktree 进行物理隔离。
```

### 步骤 3：第一轮对话直接调用“个性化服务”（Agent 绝不迷茫）
在对话第一轮，你可以像使用 Gemini 个性化服务一样随意开口：
> 👤 **用户**：*“读取我的个性化文件，准备开始重构后端模块。”*  
> 🤖 **Agent 的反应**：
> 1. Agent 绝不会问你 *“文件路径在哪？”*；
> 2. Agent 会自动查阅 `artifacts/INDEX.md` 或执行轻量嗅探；
> 3. 自动匹配到带有 `kind: profile` 或 `tags: ["preference"]` 的文件（如 `artifacts/profiles/developer-preference.md`）；
> 4. 以只读模式加载，并回答：*“已自动识别并载入个性化基准配置：[用户开发偏好与协同规范基准]，遵循简体中文、奥卡姆剃刀原则与 Clean Code 规范，准备开始重构……”*

### 步骤 4：随意重命名或移动个性化文件（抗路径断裂）
- 即使你把 `developer-preference.md` 改名为 `my_custom_rules.md`，并扔到了深层子目录 `src/docs/custom/`；
- Agent 依赖文件头部的 `urn: "urn:agent:profile:dev-style"` 或 `tags`，依然能秒级检索出来，**工作流永不断裂**！

### 步骤 5：对话归档与产物沉淀
当你讨论完一个重要方案或做完阶段性总结时：
> 👤 **用户**：*“把刚才我们讨论的登录模块鉴权方案总结归档。”*  
> 🤖 **Agent 的反应**：
> 1. 自动过滤掉推导过程中的闲聊废话；
> 2. 在 `artifacts/decisions/` 或对应目录下生成一个包含完整 YAML 头部的 `.md` 文件（如 `auth-design.md`）；
> 3. 更新 `INDEX.md`，执行 Git 原子提交；
> 4. 下游 Agent 或未来的你自己只需引用该产物即可无缝接力。

---

## 四、命令行工具使用参考（面向开发者与脚本）

所有工具均位于 `.agent/scripts/`，无任何 Python/Node 依赖：

### 1. 产物与个性化管理 (`artifact.sh`)
```bash
# 扫描所有带 YAML Frontmatter 的文件并重新生成动态目录地图
bash .agent/scripts/artifact.sh index

# 语义检索（根据 URN、标签、分类或关键词定位文件）
bash .agent/scripts/artifact.sh find "clean-code"

# 提交产物到 Git 仓库
bash .agent/scripts/artifact.sh commit "feat(artifact): archive auth architecture decision"
```

### 2. Multi-Agent 物理隔离管理 (`worktree.sh`)
```bash
# 为 Agent-Gemini 创建完全独立的物理目录与分支
bash .agent/scripts/worktree.sh create gemini

# 列出当前活动的 Agent 工作区
bash .agent/scripts/worktree.sh list

# 合并 Agent 产出的分支成果到当前分支
bash .agent/scripts/worktree.sh merge gemini

# 任务完成后安全清理 Worktree
bash .agent/scripts/worktree.sh remove gemini
```

---

## 五、设计哲学总结

* **简单（Simplicity）**：纯文本 + Git，任何终端、任何平台随时可用。
* **可靠（Reliability）**：只读防腐层切断幻觉扩散，Git 记录一切演进。
* **自由（Flexibility）**：人类拥有文件系统的绝对控制权，随便挪动文件，语义协议保驾护航。
