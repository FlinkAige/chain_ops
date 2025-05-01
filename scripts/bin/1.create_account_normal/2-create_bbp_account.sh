#!/bin/bash

# ---------------- 参数配置 ----------------
mcli="amcli -u https://chain.amaxtest.com"
#mcli="amcli -u https://aplink.armonia.fund"
creator=amax2o25o5o1
owner=$creator@active
activer=$creator@active
amaxpool=$creator
filename="bbps.txt"
logfile="run_$(date +%Y%m%d_%H%M%S).log"
failed_accounts="failed_accounts.txt"
failed_commands="failed_commands.txt"

created_count=0
transfered_count=0
failed_count=0

# ---------------- 初始化失败命令文件 ----------------
if [ ! -f "$failed_commands" ]; then
    echo "========== 脚本启动时间：$(date +'%Y-%m-%d %H:%M:%S') ==========" > "$failed_commands"
fi

# ---------------- 工具函数 ----------------
log(){
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$logfile"
}

confirm() {
    read -p "$1 [y/N]: " answer
    case "$answer" in
        [Yy]* ) return 0 ;;
        * ) echo "❌ 已取消操作。"; exit 1 ;;
    esac
}

# ---------------- 创建账户函数 ----------------
create_account(){
    if [ ! -f "$filename" ]; then
        log "❌ 文件不存在: $filename"
        exit 1
    fi

    mapfile -t accounts < "$filename"
    total_accounts=${#accounts[@]}

    for ((i=0; i<total_accounts; i++)); do
        acct="${accounts[$i]}"
        log "🛠️ 正在创建账户: $acct (第 $((i+1)) 个账户 / 共 $total_accounts 个)"

        create_cmd="$mcli system newaccount --stake-net '0.005000 AMAX' --stake-cpu '0.005000 AMAX' --buy-ram-kbytes 4 $creator $acct $owner $activer -p $creator"
        eval "$create_cmd"

        if [ $? -eq 0 ]; then
            log "✅ 创建成功: $acct"
            created_count=$((created_count+1))
        else
            log "❌ 创建失败: $acct"
            echo "$acct" >> "$failed_accounts"
            echo "$create_cmd" >> "$failed_commands"
            failed_count=$((failed_count+1))
        fi
    done
    log "📦 create_account 完成，共处理 ${total_accounts} 个账户"
}

# ---------------- 转账函数 ----------------
transfer_amax(){
    if [ ! -f "$filename" ]; then
        log "❌ 文件不存在: $filename"
        exit 1
    fi

    num_to_transfer="${1:-17}"
    transfer_amount="${2:-600.00000000 AMAX}"

    mapfile -t accounts < "$filename"
    total_accounts=${#accounts[@]}

    confirm "⚠️ 即将执行『转账 AMAX』操作！
    - 向前 $num_to_transfer 个账户
    - 每个转账金额: $transfer_amount
    - 是否继续？"

    for ((i=0; i<total_accounts && i<num_to_transfer; i++)); do
        acct="${accounts[$i]}"
        log "💰 正在转账 AMAX 从账户 $amaxpool 给账户: $acct (第 $((i+1)) 个账户 / 共 $total_accounts 个)，金额: $transfer_amount"

        result=$($mcli get currency balance amax.token "$acct")
        amax_balance=$(echo "$result" | grep "AMAX")

        if [ -z "$amax_balance" ]; then
            transfer_cmd="$mcli push action amax.token transfer '[\"$amaxpool\", \"$acct\", \"$transfer_amount\", \"\"]' -p $amaxpool"
            eval "$transfer_cmd"

            if [ $? -eq 0 ]; then
                log "✅ 转账成功: $acct"
                transfered_count=$((transfered_count+1))
            else
                log "❌ 转账失败: $acct"
                echo "$acct" >> "$failed_accounts"
                echo "$transfer_cmd" >> "$failed_commands"
                failed_count=$((failed_count+1))
            fi
        else
            log "ℹ️ 账户 $acct 已有余额: $amax_balance"
        fi
    done
    log "📦 transfer_amax 完成，共处理前 $num_to_transfer 个账户"
}

# ---------------- 汇总函数 ----------------
summary(){
    echo "---------- 📊 执行结果汇总 ----------" | tee -a "$logfile"
    echo "✅ 创建账户数   : $created_count" | tee -a "$logfile"
    echo "✅ 转账账户数   : $transfered_count" | tee -a "$logfile"
    echo "❌ 失败操作数   : $failed_count" | tee -a "$logfile"
    echo "📄 日志文件     : $logfile" | tee -a "$logfile"
    echo "📄 失败账户文件 : $failed_accounts" | tee -a "$logfile"
    echo "📄 失败命令文件 : $failed_commands" | tee -a "$logfile"
    echo "--------------------------------------"
}

# ---------------- 主程序入口 ----------------
case "$1" in
    create)
        confirm "⚠️ 即将执行『创建账户』操作，是否继续？"
        create_account
        summary
        ;;
    transfer)
        transfer_count="${2:-17}"
        transfer_amount="${3:-600.00000000 AMAX}"
        transfer_amax "$transfer_count" "$transfer_amount"
        summary
        ;;
    all)
        confirm "⚠️ 即将执行『创建账户 + 转账』全部操作，是否继续？"
        create_account
        transfer_amax
        summary
        ;;
    help|*)
        echo "📘 用法：$0 [create|transfer|all|help]"
        echo "  create         - 创建账户"
        echo "  transfer [n amount] - 向前 n 个账户转账指定金额"
        echo "    示例: $0 transfer 10 \"500.00000000 AMAX\""
        echo "  all            - 创建 + 转账"
        echo "  help           - 显示帮助"
        ;;
esac
