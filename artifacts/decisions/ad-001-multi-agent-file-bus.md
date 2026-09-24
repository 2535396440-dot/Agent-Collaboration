---
urn: "urn:agent:decision:file-bus"
kind: "decision"
title: "多 Agent 通信介质架构决策：采用文件黑板而非网络 RPC"
tags: ["architecture", "decision", "multi-agent", "blackboard", "git"]
summary: "确立采用纯 Markdown 文件 + Git Worktree 作为多 Agent 交互与知识共享的物理总线"
read_only: true
version: "1.0.0"
producer: "system-architect"
updated_at: "2026-09-24T12:30:00"
---

# 架构决策记录：采用文件黑板实现多 Agent 结果共享

## 1. 背景与问题陈述
多个 Agent（如 Gemini、OpenAI Codex、Claude 等）在协作时，传统依赖网络 RPC 或同构内存的方案存在极高的运行时耦合，且容易造成上下文爆炸或进程崩溃即丢失状态。

## 2. 决策结论
1. **统一通信介质**：所有 Agent 不直接跨网络发消息，而是将阶段性结论输出为带有标准 YAML Frontmatter 的 Markdown 文件。
2. **读写分离与只读防腐**：下游 Agent 仅能只读消费上游产物，严禁就地覆写。
3. **物理隔离**：多 Agent 并发作业时，使用 `git worktree` 分配独立的隔离目录，杜绝文件锁冲突与环境脏写。
4. **零外部依赖**：仅基于操作系统文件系统、Git 与 Bash，保证在任何新工作区 5 秒内即可无痛复用。

## 3. 积极后果与收益
- 无论用户随意移动文件或重命名，Agent 均可通过 URN / 标签实现动态语义嗅探，杜绝绝对路径断裂。
- 人类开发者可直接在本地编辑器中打开任意 `.md` 审查并介入。
