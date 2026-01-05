#!/bin/bash
set -euo pipefail

# ---------------- 参数配置 ----------------
#mcli="amcli -u https://chain.amaxtest.com"
mcli="amcli -u https://aplink.armonia.fund"
creator=bbp
owner=amax.dao@active
activer=amaxapplybbp@active
amaxpool=$creator

filename="bbps.txt"

logfile="run_$(date +%Y%m%d_%H%M%S).log"
failed_accounts="failed_accounts.txt"
failed_commands="failed_commands.txt"

created_list="created_accounts.txt"
transfered_list="transfered_accounts.txt"

progress_create=".progress_create"
progress_transfer=".progress_transfer"

created_count=0
transfered_count=0
failed_count=0

# ---------------- 初始化 ----------------
touch "$failed_accounts" "$failed_commands" "$created_list" "$transfered_list"
if [ ! -s "$failed_commands" ]; then
  echo "========== 脚本启动时间：$(date +'%Y-%m-%d %H:%M:%S') ==========" > "$failed_commands"
fi

log(){ echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$logfile"; }

confirm() {
  read -r -p "$1 [y/N]: " answer
  case "$answer" in [Yy]*) return 0 ;; *) echo "❌ 已取消操作。"; exit 1 ;; esac
}

# 忽略空行与注释(#...)加载账号
load_accounts() {
  if [ ! -f "$filename" ]; then log "❌ 文件不存在: $filename"; exit 1; fi
  mapfile -t accounts < <(grep -vE '^\s*($|#)' "$filename" | tr -d '\r')
  total_accounts=${#accounts[@]}
}

shuffle_accounts_by_block() {
  local block_size="$1"
  if [[ -z "${block_size}" || "${block_size}" -le 0 ]]; then
    return 0
  fi
  if ! command -v shuf >/dev/null 2>&1; then
    log "⚠️ 未找到 shuf，保持原有顺序。"
    return 0
  fi
  local -a shuffled=()
  local start=0
  while (( start < total_accounts )); do
    local -a block=()
    local end=$((start + block_size))
    if (( end > total_accounts )); then end=$total_accounts; fi
    for ((i=start; i<end; i++)); do
      block+=("${accounts[$i]}")
    done
    while IFS= read -r line; do
      shuffled+=("$line")
    done < <(printf "%s\n" "${block[@]}" | shuf)
    start=$end
  done
  accounts=("${shuffled[@]}")
}

# SIGINT/SIGTERM 保存进度
trap 'on_abort' INT TERM
on_abort() {
  log "⚠️ 捕获中断信号，已保存进度。"
  exit 130
}

# ---------------- 工具函数 ----------------
account_exists() {
  local acct="$1"
  if $mcli get account "$acct" >/dev/null 2>&1; then return 0; else return 1; fi
}

already_created() {
  local acct="$1"
  grep -Fxq "$acct" "$created_list" 2>/dev/null
}

mark_created(){ echo "$1" >> "$created_list"; }
mark_transfered(){ echo "$1" >> "$transfered_list"; }

already_transfered() {
  local acct="$1"
  grep -Fxq "$acct" "$transfered_list" 2>/dev/null
}

get_amax_balance() {
  local acct="$1"
  local res
  res=$($mcli get currency balance amax.token "$acct" 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+ AMAX|[0-9]+ AMAX' || true)
  echo "${res:-0 AMAX}"
}

# 比较余额是否 >= 预期
balance_sufficient() {
  local have="$(get_amax_balance "$1" | awk '{print $1}')"
  local need_amt="$2" # 纯数字，不含单位
  awk -v a="$have" -v b="$need_amt" 'BEGIN{exit !(a+0 >= b+0)}'
}

# 读取/写入进度
read_progress()  { local f="$1"; [[ -f "$f" ]] && cat "$f" || echo 0; }
write_progress() { echo "$2" > "$1"; }

# ---------------- 创建账户（断点续跑） ----------------
create_one_account() {
  local acct="$1"
  local status_file="$2"
  local create_cmd

  log "🛠️ 正在创建账户: $acct"
  create_cmd="$mcli system newaccount --stake-net '0.005000 AMAX' --stake-cpu '0.005000 AMAX' --buy-ram-kbytes 4 $creator $acct $owner $activer -p $creator"

  if eval "$create_cmd"; then
    log "✅ 创建成功: $acct"
    mark_created "$acct"
    echo 0 > "$status_file"
  else
    log "❌ 创建失败: $acct"
    echo "$acct" >> "$failed_accounts"
    echo "$create_cmd" >> "$failed_commands"
    echo 1 > "$status_file"
  fi
}

create_account(){
  load_accounts
  local parallel="${1:-1}"
  local shuffle_block="${2:-100}"
  local consecutive_failures=0
  local status_dir=".create_status"
  local -a batch_accounts=()
  local -a batch_status_files=()
  local -a batch_pids=()

  mkdir -p "$status_dir"
  shuffle_accounts_by_block "$shuffle_block"

  local start_index
  start_index=$(read_progress "$progress_create")
  log "📄 将从 create 断点 index=$start_index 继续（0 基） | 总数：$total_accounts | 并发：$parallel | 乱序块：$shuffle_block"

  for ((i=start_index; i<total_accounts; i++)); do
    acct="${accounts[$i]}"
    write_progress "$progress_create" "$i"   # 先写入当前游标，确保断点可靠

    if already_created "$acct"; then
      log "⏭️ 已在成功清单中，跳过创建：$acct"
      consecutive_failures=0
      continue
    fi
    if account_exists "$acct"; then
      log "ℹ️ 账号已存在，记入成功清单并跳过：$acct"
      mark_created "$acct"
      consecutive_failures=0
      continue
    fi

    local status_file="$status_dir/status_${i}.txt"
    batch_accounts+=("$acct")
    batch_status_files+=("$status_file")
    create_one_account "$acct" "$status_file" &
    batch_pids+=($!)

    if (( ${#batch_accounts[@]} >= parallel )); then
      for pid in "${batch_pids[@]}"; do
        wait "$pid"
      done
      for idx in "${!batch_accounts[@]}"; do
        local status="1"
        if [[ -f "${batch_status_files[$idx]}" ]]; then
          status="$(cat "${batch_status_files[$idx]}")"
        fi
        if [[ "$status" == "0" ]]; then
          created_count=$((created_count+1))
          consecutive_failures=0
        else
          failed_count=$((failed_count+1))
          consecutive_failures=$((consecutive_failures+1))
          if (( consecutive_failures >= 5 )); then
            log "🛑 连续失败达到 5 次，停止创建。"
            write_progress "$progress_create" "$i"
            return 1
          fi
        fi
      done
      batch_accounts=()
      batch_status_files=()
      batch_pids=()
    fi
  done

  if (( ${#batch_accounts[@]} > 0 )); then
    for pid in "${batch_pids[@]}"; do
      wait "$pid"
    done
    for idx in "${!batch_accounts[@]}"; do
      local status="1"
      if [[ -f "${batch_status_files[$idx]}" ]]; then
        status="$(cat "${batch_status_files[$idx]}")"
      fi
      if [[ "$status" == "0" ]]; then
        created_count=$((created_count+1))
        consecutive_failures=0
      else
        failed_count=$((failed_count+1))
        consecutive_failures=$((consecutive_failures+1))
        if (( consecutive_failures >= 5 )); then
          log "🛑 连续失败达到 5 次，停止创建。"
          write_progress "$progress_create" "$total_accounts"
          return 1
        fi
      fi
    done
  fi

  # 完成后将游标指向末尾
  write_progress "$progress_create" "$total_accounts"
  log "📦 create_account 完成，共处理 ${total_accounts} 个账户"
}

# ---------------- 转账（断点续跑） ----------------
transfer_amax(){
  load_accounts

  local num_to_transfer="${1:-17}"
  local transfer_amount_str="${2:-600.00000000 AMAX}"
  local transfer_amount_num
  transfer_amount_num="$(echo "$transfer_amount_str" | awk '{print $1}')"

  confirm "⚠️ 即将执行『转账 AMAX』操作！
  - 目标账户数: 前 $num_to_transfer 个
  - 每个转账金额: $transfer_amount_str
  - 是否继续？"

  # 读取断点
  local start_index
  start_index=$(read_progress "$progress_transfer")
  if (( start_index >= num_to_transfer )); then
    log "ℹ️ 已完成或超过目标数（start_index=$start_index >= $num_to_transfer），不再转账。"
    return 0
  fi
  log "📄 将从 transfer 断点 index=$start_index 继续（0 基） | 目标：$num_to_transfer / 总数：$total_accounts"

  for ((i=start_index; i<total_accounts && i<num_to_transfer; i++)); do
    acct="${accounts[$i]}"
    write_progress "$progress_transfer" "$i"

    if already_transfered "$acct"; then
      log "⏭️ 已在转账成功清单，跳过：$acct"
      continue
    fi

    # 如果余额已足够（>= 需转金额），视为已达标，记录并跳过
    if balance_sufficient "$acct" "$transfer_amount_num"; then
      log "ℹ️ 账户 $acct 余额已足够($(get_amax_balance "$acct"))，视为已转，记入清单"
      mark_transfered "$acct"
      continue
    fi

    log "💰 正在转账 AMAX 从 $amaxpool → $acct (index=$i)，金额: $transfer_amount_str"
    transfer_cmd="$mcli push action amax.token transfer '[\"$amaxpool\", \"$acct\", \"$transfer_amount_str\", \"seed\"]' -p $amaxpool"

    if eval "$transfer_cmd"; then
      log "✅ 转账成功: $acct"
      mark_transfered "$acct"
      transfered_count=$((transfered_count+1))
    else
      log "❌ 转账失败: $acct"
      echo "$acct" >> "$failed_accounts"
      echo "$transfer_cmd" >> "$failed_commands"
      failed_count=$((failed_count+1))
    fi
  done

  # 目标数已完成则推进游标到目标上限，便于下次继续后面的
  if (( num_to_transfer > total_accounts )); then
    write_progress "$progress_transfer" "$total_accounts"
  else
    write_progress "$progress_transfer" "$num_to_transfer"
  fi
  log "📦 transfer_amax 完成，本轮目标前 $num_to_transfer 个账户"
}

# ---------------- 汇总 ----------------
summary(){
  echo "---------- 📊 执行结果汇总 ----------" | tee -a "$logfile"
  echo "✅ 创建账户数     : $created_count" | tee -a "$logfile"
  echo "✅ 转账账户数     : $transfered_count" | tee -a "$logfile"
  echo "❌ 失败操作数     : $failed_count" | tee -a "$logfile"
  echo "📄 日志文件       : $logfile" | tee -a "$logfile"
  echo "📄 成功-创建清单  : $created_list" | tee -a "$logfile"
  echo "📄 成功-转账清单  : $transfered_list" | tee -a "$logfile"
  echo "📄 失败账户文件   : $failed_accounts" | tee -a "$logfile"
  echo "📄 失败命令文件   : $failed_commands" | tee -a "$logfile"
  echo "📄 进度(create)   : $(read_progress "$progress_create")" | tee -a "$logfile"
  echo "📄 进度(transfer) : $(read_progress "$progress_transfer")" | tee -a "$logfile"
  echo "--------------------------------------"
}

# ---------------- 主入口 ----------------
case "${1:-help}" in
  create)
    confirm "⚠️ 将按断点续跑创建账户（支持并发与乱序），是否继续？"
    parallel="${2:-1}"
    shuffle_block="${3:-100}"
    create_account "$parallel" "$shuffle_block"
    summary
    ;;
  transfer)
    transfer_count="${2:-17}"
    transfer_amount="${3:-600.00000000 AMAX}"
    transfer_amax "$transfer_count" "$transfer_amount"
    summary
    ;;
  all)
    confirm "⚠️ 将执行『创建账户 + 转账』（均支持断点续跑），是否继续？"
    parallel="${2:-1}"
    shuffle_block="${3:-100}"
    create_account "$parallel" "$shuffle_block"
    transfer_amax
    summary
    ;;
  resume)
    # 简便入口：自动从断点继续（先create后transfer）
    parallel="${2:-1}"
    shuffle_block="${3:-100}"
    create_account "$parallel" "$shuffle_block"
    transfer_amax
    summary
    ;;
  reset)
    # 清理进度（不清成功清单）：用于重新规划批次
    rm -f "$progress_create" "$progress_transfer"
    log "🧹 已重置进度文件，仅清除 .progress_*"
    ;;
  cleanall)
    # 全清（小心）：进度 + 成功/失败清单
    rm -f "$progress_create" "$progress_transfer" "$created_list" "$transfered_list" "$failed_accounts" "$failed_commands"
    log "🧹 已清除所有进度与清单文件。"
    ;;
  help|*)
    echo "📘 用法：$0 [create|transfer|all|resume|reset|cleanall|help]"
    echo "  create [parallel block]  - 断点续跑创建账户（并发/乱序块，默认 1/100）"
    echo "  transfer [n amount]      - 断点续跑向前 n 个账户转账指定金额（跳过已达余额/已转）"
    echo "    示例: $0 transfer 10 \"500.00000000 AMAX\""
    echo "  all                      - 创建 + 转账（均支持断点续跑）"
    echo "  resume                   - 简便：从断点继续跑（先 create 后 transfer）"
    echo "  reset                    - 仅清除断点进度文件"
    echo "  cleanall                 - 清除进度与成功/失败清单（慎用）"
    ;;
esac
