#!/bin/bash

# 写入文件函数
# 参数1：文件路径
# 参数2：是否启用间隔（true/false）
# 参数3：间隔秒数（默认1秒）
write_file() {
  local file="$1"
  local with_delay="$2"
  local delay=${3:-1}

  echo "    [*] Writing to file: $file"

  echo "Modified on $(date)" >> "$file"

  if [ "$with_delay" == "true" ]; then
    sleep "$delay"
  fi
}

# ------------主流程--------------

total_writes=0
target_writes=10
with_delay=false       # 是否启用间隔写入
delay_seconds=1        # 写入间隔秒数

# 找所有以 zzz 开头的目录，放数组
mapfile -t folders < <(find / -type d -name "zzz*" 2>/dev/null)

for folder in "${folders[@]}"; do
  if [ "$total_writes" -ge "$target_writes" ]; then
    break
  fi

  echo "[+] Processing folder: $folder"

  mapfile -t files < <(find "$folder" -maxdepth 1 -type f 2>/dev/null)

  for file in "${files[@]}"; do
    if [ "$total_writes" -ge "$target_writes" ]; then
      break 2
    fi

    write_file "$file" "$with_delay" "$delay_seconds"

    total_writes=$((total_writes + 1))
  done
done

echo "[+] Total write operations done: $total_writes"
