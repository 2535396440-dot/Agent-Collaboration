#!/usr/bin/env bash
# ==============================================================================
# F-Blackboard: 产物索引与语义寻址工具 (纯 Bash + Git 实现，零外部依赖)
# ==============================================================================

ACTION="${1:-help}"
PARAM="$2"
INDEX_FILE="artifacts/INDEX.md"

show_help() {
  echo "F-Blackboard 产物与个性化文件管理工具"
  echo "用法: bash .agent/scripts/artifact.sh <命令> [参数]"
  echo ""
  echo "可用命令:"
  echo "  index                 扫描工作区所有标准产物，自动重新生成 artifacts/INDEX.md"
  echo "  find <关键词/URN>     根据 URN、标签、类别或标题快速定位产物文件（抗路径迁移）"
  echo "  commit <提交说明>     将产物变动原子提交到 Git 仓库，确保版本可追溯"
  echo "  help                  显示本帮助信息"
  echo ""
}

# 严格检测 Markdown 文件头部是否包含合法的 YAML Frontmatter 以及指定字段
is_valid_artifact() {
  local file="$1"
  awk '
    BEGIN { valid=0; in_fm=0 }
    NR == 1 && /^---[[:space:]]*$/ { in_fm=1; next }
    in_fm == 1 && /^---[[:space:]]*$/ { exit }
    in_fm == 1 && /^[[:space:]]*urn:[[:space:]]*/ { valid=1 }
    END { exit (valid == 1 ? 0 : 1) }
  ' "$file"
}

extract_field() {
  local file="$1"
  local field="$2"
  # 提取第 1 个 frontmatter 中的指定字段值 (去除 CRLF、双引号、单引号与首尾空格)
  awk -v f="$field" '
    BEGIN { in_fm=0 }
    NR == 1 && /^---[[:space:]]*$/ { in_fm=1; next }
    in_fm == 1 && /^---[[:space:]]*$/ { exit }
    in_fm == 1 && $0 ~ "^[[:space:]]*" f ":" {
      val = $0;
      sub("^[[:space:]]*" f ":[[:space:]]*", "", val);
      gsub(/\r/, "", val);
      gsub(/^["'\''"]+|["'\''"]+$/, "", val);
      print val;
      exit;
    }
  ' "$file"
}

get_all_markdown_files() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git ls-files --cached --others --exclude-standard "*.md" | grep -v "^\.agent/" || true
  else
    find . -name "*.md" -not -path "*/.git/*" -not -path "*/.worktrees/*" -not -path "*/.agent/*"
  fi
}

case "$ACTION" in
  index)
    echo "🔍 正在扫描工作区内包含标准 YAML Frontmatter 的 Markdown 产物..."
    mkdir -p artifacts

    cat << 'EOF' > "$INDEX_FILE"
# 产物与个性化配置动态索引清单（Artifacts & Profiles Index）

> **自动生成与自省文件**：本索引由 F-Blackboard 协议动态维护。
> 当用户随意迁移或重命名文件时，可通过运行 `bash .agent/scripts/artifact.sh index` 重新生成。
> 任何 Agent 启动时均可通过查阅本表，以**只读模式**精准调阅所需上下文。

| 唯一标识 (URN) | 类型 | 标题 | 标签 | 相对路径 | 摘要 |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

    count=0
    for file in $(get_all_markdown_files); do
      # 忽略自身 INDEX.md
      [ "$file" = "$INDEX_FILE" ] && continue
      [ "$file" = "./$INDEX_FILE" ] && continue

      if [ -f "$file" ] && is_valid_artifact "$file"; then
        urn=$(extract_field "$file" "urn")
        kind=$(extract_field "$file" "kind")
        title=$(extract_field "$file" "title")
        tags=$(extract_field "$file" "tags")
        summary=$(extract_field "$file" "summary")

        [ -z "$kind" ] && kind="deliverable"
        [ -z "$title" ] && title=$(basename "$file")
        [ -z "$tags" ] && tags="[]"
        [ -z "$summary" ] && summary="无摘要"

        # 转义表格中的管道符
        summary_clean=$(echo "$summary" | tr '|' '/')
        title_clean=$(echo "$title" | tr '|' '/')

        echo "| \`$urn\` | \`$kind\` | $title_clean | \`$tags\` | [$file](file:///$file) | $summary_clean |" >> "$INDEX_FILE"
        count=$((count + 1))
      fi
    done

    echo "✅ 索引构建完成！共收录 $count 个标准产物。清单已保存至: $INDEX_FILE"
    ;;

  find)
    if [ -z "$PARAM" ]; then
      echo "❌ 错误: 请输入要查找的关键词、URN 或 Tag，例如: bash .agent/scripts/artifact.sh find profile"
      exit 1
    fi
    echo "🔎 正在语义检索匹配 [$PARAM] 的产物文件..."
    found=0
    for file in $(get_all_markdown_files); do
      [ "$file" = "$INDEX_FILE" ] && continue
      [ "$file" = "./$INDEX_FILE" ] && continue

      if [ -f "$file" ] && is_valid_artifact "$file"; then
        urn=$(extract_field "$file" "urn")
        kind=$(extract_field "$file" "kind")
        title=$(extract_field "$file" "title")
        tags=$(extract_field "$file" "tags")
        summary=$(extract_field "$file" "summary")

        # 检查是否匹配 URN、kind、tags、title 或 summary
        if echo "$urn $kind $title $tags $summary" | grep -i "$PARAM" >/dev/null 2>&1; then
          echo ""
          echo "🎯 命中目标: $file"
          echo "   • URN:     $urn"
          echo "   • 类型:     $kind"
          echo "   • 标题:     $title"
          echo "   • 标签:     $tags"
          echo "   • 摘要:     $summary"
          found=$((found + 1))
        fi
      fi
    done

    if [ "$found" -eq 0 ]; then
      echo "⚠️ 未找到匹配 [$PARAM] 的标准产物文件。"
    else
      echo ""
      echo "✨ 共检索到 $found 个匹配产物。"
    fi
    ;;

  commit)
    MSG="${PARAM:-chore(artifact): update artifacts and index}"
    echo "💾 正在持久化产物与索引到 Git..."
    git add artifacts/
    git commit -m "$MSG" || echo "ℹ️ 无新产物变更需要提交。"
    echo "✅ Git 原子提交完成！当前产物状态已不可篡改并支持随时版本回滚。"
    ;;

  help|*)
    show_help
    ;;
esac
