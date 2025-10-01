#!/bin/bash
# 用法: ./diff_accounts.sh all.txt gen.txt

ALL=$1
GEN=$2

if [ -z "$ALL" ] || [ -z "$GEN" ]; then
  echo "用法: $0 all.txt gen.txt"
  exit 1
fi

# 1. 清理空行和首尾空白
sed -e 's/^[ \t]*//;s/[ \t]*$//' -e '/^$/d' "$ALL" > all.clean
sed -e 's/^[ \t]*//;s/[ \t]*$//' -e '/^$/d' "$GEN" > gen.clean

# 2. 差集：all.clean - gen.clean
grep -Fvx -f gen.clean all.clean > diff.txt

# 3. 输出结果
echo "清理后的文件: all.clean / gen.clean"
echo "差集已保存到 diff.txt，共 $(wc -l < diff.txt) 行"