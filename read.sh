#!/bin/bash

# 读取文件函数
# 参数1：文件路径
# 参数2：是否启用间隔（true/false）
# 参数3：间隔秒数（可选，默认1秒）
read_file() {
  local file="$1"
  local with_delay="$2"
  local delay=${3:-1}

  echo "    [*] Reading file: $file"

  cat "$file" > /dev/null

  if [ "$with_delay" == "true" ]; then
    sleep "$delay"
  fi
}

# 示例用法：
# read_file "/path/to/file.txt" true 2  # 读文件，间隔2秒
# read_file "/path/to/file.txt" false   # 读文件，无间隔

# ------------主流程--------------

total_reads=0
target_reads=10
with_delay=false     # 是否启用间隔读取
delay_seconds=1     # 读取间隔秒数

# 找所有以 zzz 开头的目录，放数组
mapfile -t folders < <(find / -type d -name "zzz*" 2>/dev/null)

for folder in "${folders[@]}"; do
  if [ "$total_reads" -ge "$target_reads" ]; then
    break
  fi

  echo "[+] Processing folder: $folder"

  mapfile -t files < <(find "$folder" -maxdepth 1 -type f 2>/dev/null)

  for file in "${files[@]}"; do
    if [ "$total_reads" -ge "$target_reads" ]; then
      break 2
    fi

    read_file "$file" "$with_delay" "$delay_seconds"

    total_reads=$((total_reads + 1))
  done
done

echo "[+] Total read operations done: $total_reads"
