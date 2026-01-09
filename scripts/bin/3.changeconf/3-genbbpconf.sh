#!/bin/bash
# =========================================================
#  Script: 3-genbbpconf.sh
#  功能: 从 data.json 中提取 id 区间内的 bbp_account，
#       生成 producer-name 配置文件，命名为：
#       80-bbpconf-<YYMMDD>-<HHMM>-internal_voter.conf
#  作者: joss
# =========================================================

set -euo pipefail

# ---------- 可配置参数 ----------
INPUT_FILE="${1:-all.votes.json}"       # 默认读取 data.json
MIN_ID="${MIN_ID:-3100}"           # 可通过环境变量或命令行改
MAX_ID="${MAX_ID:-4100}"
OUT_DIR="./"                       # 输出目录（默认当前）
# --------------------------------

# 检查 jq 是否安装
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ 错误: jq 未安装，请执行 'sudo apt install jq' 或 'brew install jq'"
  exit 1
fi

# 检查输入文件
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ 错误: 未找到输入文件 $INPUT_FILE"
  exit 1
fi

# 生成动态文件名
DATE_STR=$(date +"%y%m%d-%H%M")
OUTPUT_FILE="${OUT_DIR}/80-bbpconf-${DATE_STR}-internal_voter.conf"

echo "🔍 生成文件: $OUTPUT_FILE"
echo "📦 读取: $INPUT_FILE"
echo "📊 筛选范围: id > $MIN_ID 且 id <= $MAX_ID"

# 执行提取
jq -r --argjson min "$MIN_ID" --argjson max "$MAX_ID" \
  '.[] | select(.id > $min and .id <= $max) | "producer-name = " + .bbp_account' \
  "$INPUT_FILE" > "$OUTPUT_FILE"

echo "✅ 生成完成: $OUTPUT_FILE"
echo "📄 文件前 10 行预览:"
head -n 10 "$OUTPUT_FILE"
