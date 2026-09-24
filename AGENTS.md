# AGENTS.md - 工作区智能体协同契约与个性化服务指引

> **致所有进入本工作区的 AI 智能体（Gemini, Claude, Codex, Cursor 等）**：
> 本工作区遵循 **`F-Blackboard`（文件驱动黑板与轻量产物 Pub-Sub 协议）**。
> 无论你是主控 Agent 还是下游执行 Agent，在开始任何任务之前，请严格遵循以下运行时规则：

---

## 核心规则一：第一轮对话的“个性化服务”自适应读取（绝不迷茫）

当用户在初次对话或任务开启时说出如下类似指令：
> *“读取我的个性化文件”*  
> *“参考我的开发习惯/项目偏好”*  
> *“按照上次的架构决策继续执行”*  

### 你必须遵循的寻址流程：
1. **绝不依赖写死的绝对路径**：用户可能随时修改了个性化文件的路径、目录层级或标题。
2. **主动执行“语义与元数据嗅探”**：
   * 优先查看 `artifacts/INDEX.md` 中的产物登记列表；
   * 若无索引或未命中，使用轻量检索工具（如 `git grep "kind: profile"` 或检索 `tags`）寻找带有 YAML Frontmatter 的 Markdown 文件；
   * 通过比对文件头部的 `urn`、`kind`（如 `profile` / `memory` / `decision`）与 `tags`，自动识别用户所指的目标。
3. **只读挂载与反馈**：
   * 找到目标文件后，以**只读模式（Read-Only）**加载内容；
   * 向用户明确反馈一句你已加载的配置（如：*“已自动识别并加载个性化配置：[相对路径]，遵循其中的架构规范...”*）；
   * 将该文件中的所有要求作为本会话的不可变公理约束。

---

## 核心规则二：对话总结即“标准产物归档”

当用户发出归档、总结或沉淀指令（如 *“总结刚才的结论，保存为个性化偏好/架构决策”*）时：
1. **坚决剥离口水话**：严禁把双方完整的交互对话流原样堆砌进文件。
2. **萃取高信噪比产物**：提取**核心结论**、**配置参数**、**数据契约**及**约束清单**。
3. **注入标准 YAML Frontmatter**：
   ```yaml
   ---
   urn: "urn:agent:<kind>:<unique-slug>"
   kind: "profile" # 或 "decision", "memory", "deliverable"
   title: "<清晰明确的人类可读标题>"
   tags: ["<关键词1>", "<关键词2>"]
   summary: "<一句话摘要，阐明本产物核心作用>"
   read_only: true
   version: "1.0.0"
   ---
   ```
4. **落盘与 Git 自动持久化**：
   * 默认写入 `artifacts/` 相应目录下（如 `artifacts/profiles/` 或 `artifacts/decisions/`）；
   * 提炼更新 `artifacts/INDEX.md` 索引清单；
   * 执行 `git commit` 将产物持久化，确保版本可回溯、防篡改。

---

## 核心规则三：多 Agent 协作环境下的物理隔离与只读防腐

1. **只读防腐（Read-Only Consumption）**：
   * 上游 Agent 产出的 Markdown 结论，下游 Agent 仅能**作为输入阅读**，禁止直接原地编辑覆盖；
   * 如有修正，应由当前 Agent 派生新版本文件（如更新 `version: "1.1.0"`）或生成下游专属的任务交付物。
2. **环境隔离（Git Worktree）**：
   * 若当前属于多 Agent 并发操作模式，严禁直接在主工作区并发写代码；
   * 使用 `.agent/scripts/worktree.sh create <agent-name>` 在独立的 `.worktrees/<agent-name>` 下作业，通过 Git 分支和产物合并完成协作交接。

---

## 协议详细技术参考
完整 IO 标准规范请见：[.agent/PROTOCOL.md](file:///.agent/PROTOCOL.md)
辅助工具脚本请见：[.agent/scripts/](file:///.agent/scripts/)
默认产物池与索引请见：[artifacts/INDEX.md](file:///artifacts/INDEX.md)
