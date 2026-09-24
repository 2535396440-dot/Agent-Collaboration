# 产物与个性化配置动态索引清单（Artifacts & Profiles Index）

> **自动生成与自省文件**：本索引由 F-Blackboard 协议动态维护。
> 当用户随意迁移或重命名文件时，可通过运行 `bash .agent/scripts/artifact.sh index` 重新生成。
> 任何 Agent 启动时均可通过查阅本表，以**只读模式**精准调阅所需上下文。

| 唯一标识 (URN) | 类型 | 标题 | 标签 | 相对路径 | 摘要 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `urn:agent:decision:file-bus` | `decision` | 多 Agent 通信介质架构决策：采用文件黑板而非网络 RPC | `["architecture", "decision", "multi-agent", "blackboard", "git"]` | [artifacts/decisions/ad-001-multi-agent-file-bus.md](file:///artifacts/decisions/ad-001-multi-agent-file-bus.md) | 确立采用纯 Markdown 文件 + Git Worktree 作为多 Agent 交互与知识共享的物理总线 |
| `urn:agent:profile:dev-style` | `profile` | 用户开发偏好与协同规范基准 | `["profile", "coding-style", "preference", "clean-code"]` | [artifacts/profiles/developer-preference.md](file:///artifacts/profiles/developer-preference.md) | 定义了用户的编码风格、与 AI 交互时的沟通模式、工程极简原则与技术栈偏好 |
