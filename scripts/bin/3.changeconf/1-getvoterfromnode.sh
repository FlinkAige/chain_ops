#!/bin/bash
set -euo pipefail

# amnod_url=https://expnode.amaxscan.io
amnod_url=https://aplink.armonia.fund
mcli="amcli -u ${amnod_url}"

has_more=true
next_key=0

num=0               # 已写入总数
max_num=20000        # 总上限
page_limit=500      # 每次请求多少条，别等于 max_num，给分页留余地

file=all.votes.json
: > "$file"  # 清空文件
printf '[' > "$file"

first=true  # 控制是否需要写入逗号

while [[ "$has_more" == true ]] && (( num < max_num )); do
  # 本页还允许拿多少条
  remain=$(( max_num - num ))
  limit=$(( remain < page_limit ? remain : page_limit ))

  prods_info=$($mcli get table amaxapplybbp amaxapplybbp voters \
    -l "$limit" --index 1 --key-type i128 -L "$next_key")

  count=$(jq '.rows | length' <<<"$prods_info")
  echo "got producer count (this page): $count"

  # 用进程替换，避免产生子 shell（从而可以正确更新 num/first）
  while IFS= read -r row; do
    if [[ "$first" == true ]]; then
      first=false
    else
      printf ',' >> "$file"
    fi
    printf '%s\n' "$row" >> "$file"
    num=$(( num + 1 ))
    if (( num >= max_num )); then
      break
    fi
  done < <(jq -c '.rows[]' <<<"$prods_info")

  has_more=$(jq -r '.more' <<<"$prods_info")
  next_key=$(jq -r '.next_key' <<<"$prods_info")
done

printf ']' >> "$file"

echo "✅ Done. Wrote $num items to $file"
# 可选：校验 JSON 合法性
# jq . "$file" >/dev/null && echo "JSON OK"
