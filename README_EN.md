# Lightweight Multi-Agent Collaboration

**[简体中文](README.md) | [English](README_EN.md)**

> **Overview**: A lightweight file-driven blackboard and asynchronous collaboration specification for multi-agent systems, built purely upon standard Markdown, Git, and the host operating system's filesystem. Featuring zero external service dependencies, native anti-tampering (read-only consumer pattern), and path-resilient semantic addressing, it is designed for any local environment and heterogeneous LLM agents (Gemini, Claude, OpenAI Codex, Cursor, etc.).

> [!NOTE]
> **Platform Disclaimer**:  
> This project is designed, tested, and optimized specifically for the **Google Antigravity** architecture and its customization ecosystem (Skills / Rules / Customizations).  
> While the underlying protocol (Markdown + Git + Bash) is universally portable, users operating on other AI coding platforms (such as Cursor, Claude Code, OpenAI Codex, Aider, etc.) should adapt the rule configurations (e.g., `.cursorrules`, `CLAUDE.md`, or system prompts) according to their platform's specific guidelines.

---

## 1. Core Problems & Design Principles

1. **Solving the Multi-Agent Silo Problem**: Upstream agents produce structured Markdown deliverables; downstream agents subscribe and consume them in read-only mode, eliminating context pollution and lost-in-the-middle degradation.
2. **Eliminating the "Discovery & Indexing Crisis" (Discovery Problem)**:
   - Prevents prompt context explosions caused by blindly globbing and dumping tens or hundreds of files into the LLM context;
   - Implements **Dual-Layer Decoupled Discovery**:
     - **Layer 1 (Lightweight Metadata Map)**: `artifacts/INDEX.md` maintains a compact table of URNs, tags, and one-sentence summaries (~20 tokens per item);
     - **Layer 2 (Out-of-Band OS Search)**: For large catalogs, `artifact.sh find "<keyword>"` delegates matching to the host OS filesystem (grep/awk) in milliseconds with **0 token cost**, returning only the single matched relative path.
3. **Eliminating LLM Probabilistic Sampling Drift (Prompts $\rightarrow$ Skill & State Machine)**:
   - Encoded as a formal, deterministic operational specification: `.agent/skills/f-blackboard/SKILL.md`;
   - Structured within `AGENTS.md` as an ironclad state machine contract to ensure uniform behavior across different model vendors.
4. **[Core Invariant] Strict Inertia (Zero Pre-Reading)**:
   - Agents **MUST NOT** proactively scan, pre-read, load, or hypothesize any user preferences, personal profiles, or historical decisions upon session launch;
   - Agents must remain in a completely neutral, clean-slate state;
   - Profile loading is triggered **ONLY** upon explicit user instructions (e.g., *"Read my personalization profile"*).
5. **Pure Mechanism Code with Zero Pre-baked Bias**:
   - The workspace contains no pre-baked personal opinions or preferences; standard schemas are cleanly maintained as templates in `.agent/templates/`.

---

## 2. Workspace Directory Structure

```
sumagent/
├── AGENTS.md                  # [Core Entry] State machine contract read by any entering agent
├── .agent/
│   ├── PROTOCOL.md            # [Technical Specification] Full IO specs, URN schema, Pub-Sub & Worktree isolation
│   ├── skills/
│   │   └── f-blackboard/      # [Official Skill] Antigravity-compliant SOP (SKILL.md)
│   │       └── SKILL.md
│   ├── templates/             # [Mechanism Schemas] Blank artifact schemas (no personal bias)
│   │   ├── profile.template.md
│   │   └── decision.template.md
│   └── scripts/               # [Zero-Dependency Tooling] Pure Bash + Git helper scripts
│       ├── artifact.sh        # Dynamic catalog generation, out-of-band search & atomic commits
│       └── worktree.sh        # Agent physical isolation via Git Worktree (create / list / merge)
├── artifacts/                 # [Blackboard Pool] Pure clean-slate data pool
│   ├── INDEX.md               # Dynamic metadata catalog (0 items initially, generated on-demand)
│   ├── profiles/              # Personalization profiles directory (.gitkeep)
│   └── decisions/             # Architecture decision records directory (.gitkeep)
├── try.md                     # Initial research on open-source multi-agent state sharing paradigms
├── README.md                  # Chinese Documentation
└── README_EN.md               # This Document (English)
```

---

## 3. Quick Start & Command Reference

### 1. 10-Second Setup in Any New Workspace
Simply copy `AGENTS.md` and the `.agent/` folder to the root of any new repository, then run `git init`.

### 2. User Dialogue Demonstration
* **Standard Queries (Default State)**: Ask general coding/refactoring questions $\rightarrow$ The agent stays purely neutral and objective, never pre-reading personal profiles.
* **On-Demand Consumption**: User commands *"Read my personalization profile"* or *"Reference our previous architecture decision"* $\rightarrow$ The agent triggers Procedure 1, retrieves the path via out-of-band search, and mounts it strictly as a read-only constraint.
* **Distill & Archive**: User commands *"Summarize our discussion and archive it as an architecture decision"* $\rightarrow$ The agent triggers Procedure 2, strips conversational fluff, injects YAML Frontmatter, writes to `artifacts/`, updates `INDEX.md`, and commits to Git.

### 3. Shell Tooling Commands
```bash
# Scan workspace and rebuild the compact metadata catalog (INDEX.md)
bash .agent/scripts/artifact.sh index

# Out-of-band semantic search (Locate target files in ms with 0 token overhead)
bash .agent/scripts/artifact.sh find "<keyword or URN>"

# Atomically commit artifacts to Git
bash .agent/scripts/artifact.sh commit "chore(artifact): archive ..."

# Create an isolated physical Git Worktree for an agent
bash .agent/scripts/worktree.sh create <agent_name>
```

---

## 4. License

This project is licensed under the [MIT License](LICENSE).

