#!/usr/bin/env bash
# ==============================================================================
# F-Blackboard: Agent Git Worktree 物理隔离与协作管理脚本
# 零外部依赖：纯 Git + Bash
# ==============================================================================

set -e

ACTION="${1:-help}"
AGENT_NAME="$2"
WORKTREE_BASE_DIR=".worktrees"

show_help() {
  echo "F-Blackboard Agent Worktree 隔离管理工具"
  echo "用法: bash .agent/scripts/worktree.sh <命令> [Agent名称]"
  echo ""
  echo "可用命令:"
  echo "  create <agent_name>   为指定的 Agent 创建独立隔离的 Git Worktree"
  echo "  list                  列出当前所有活动的 Agent Worktree"
  echo "  remove <agent_name>   移除指定的 Agent Worktree 并清理资源"
  echo "  merge <agent_name>    将指定 Agent 分支的成果合并回当前主分支"
  echo "  help                  显示本帮助信息"
  echo ""
}

case "$ACTION" in
  create)
    if [ -z "$AGENT_NAME" ]; then
      echo "❌ 错误: 请指定 Agent 名称，例如: bash .agent/scripts/worktree.sh create gemini"
      exit 1
    fi
    TARGET_DIR="${WORKTREE_BASE_DIR}/${AGENT_NAME}"
    BRANCH_NAME="agent/${AGENT_NAME}"

    if [ -d "$TARGET_DIR" ]; then
      echo "⚠️ 警告: Worktree 目录 $TARGET_DIR 已存在。"
      exit 0
    fi

    echo "🚀 正在为 Agent [$AGENT_NAME] 创建独立物理工作区..."
    mkdir -p "$WORKTREE_BASE_DIR"

    # 如果分支已存在直接检出，不存在则创建
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
      git worktree add "$TARGET_DIR" "$BRANCH_NAME"
    else
      git worktree add -b "$BRANCH_NAME" "$TARGET_DIR" HEAD
    fi

    echo "✅ 成功创建 Agent 独立工作区: $TARGET_DIR"
    echo "📍 分支: $BRANCH_NAME"
    echo "💡 Agent 可以在此隔离目录下安全作业，不会干扰主工作区。"
    ;;

  list)
    echo "📋 当前活动的 Git Worktree 列表:"
    git worktree list
    ;;

  remove)
    if [ -z "$AGENT_NAME" ]; then
      echo "❌ 错误: 请指定要移除的 Agent 名称。"
      exit 1
    fi
    TARGET_DIR="${WORKTREE_BASE_DIR}/${AGENT_NAME}"
    echo "🧹 正在移除 Agent [$AGENT_NAME] 的 Worktree..."
    git worktree remove "$TARGET_DIR" --force 2>/dev/null || rm -rf "$TARGET_DIR"
    git worktree prune
    echo "✅ Agent [$AGENT_NAME] 的工作区已安全清理。"
    ;;

  merge)
    if [ -z "$AGENT_NAME" ]; then
      echo "❌ 错误: 请指定要合并的 Agent 名称。"
      exit 1
    fi
    BRANCH_NAME="agent/${AGENT_NAME}"
    echo "🔄 正在将 Agent 分支 [$BRANCH_NAME] 合并到当前分支..."
    git merge --no-ff "$BRANCH_NAME" -m "merge: incorporate deliverables from $BRANCH_NAME"
    echo "✅ 合并完成！成果已同步至当前分支。"
    ;;

  help|*)
    show_help
    ;;
esac
