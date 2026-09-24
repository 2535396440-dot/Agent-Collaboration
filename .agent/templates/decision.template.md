---
urn: "urn:agent:decision:{{DECISION_SLUG}}"
kind: "decision"
title: "{{DECISION_TITLE}}"
tags: ["{{TAG_1}}", "{{TAG_2}}"]
summary: "{{DECISION_SUMMARY}}"
read_only: true
version: "1.0.0"
producer: "{{PRODUCER_NAME}}"
updated_at: "{{ISO_TIMESTAMP}}"
---

# {{DECISION_TITLE}}

## 1. 背景与上下文
- {{CONTEXT_DESCRIPTION}}

## 2. 核心决策项（供下游只读消费）
1. **决策 1**：{{DECISION_ITEM_1}}
2. **决策 2**：{{DECISION_ITEM_2}}

## 3. 输出数据契约（可选）
```json
{
  "contract_version": "1.0.0"
}
```

