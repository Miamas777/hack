#!/bin/bash

# 删除文件函数
# 参数1：文件路径
# 参数2：是否启用间隔（true/false）
# 参数3：间隔秒数（默认1秒）
delete_file() {
  local file="$1"
  local with_delay="$2"
  local delay=${3:-1}

  echo "    [*] Deleting file: $file"

  rm -f "$file"

  if [ "$with_delay" == "true" ]; then
    sleep "$delay"
  fi
}

# ------------主流程--------------

total_deletes=0
target_deletes=10
with_delay=false       # 是否启用间隔删除
delay_seconds=1        # 删除间隔秒数

# 找所有以 zzz 开头的目录
mapfile -t folders < <(find / -type d -name "zzz*" 2>/dev/null)

for folder in "${folders[@]}"; do
  if [ "$total_deletes" -ge "$target_deletes" ]; then
    break
  fi

  echo "[+] Processing folder: $folder"

  mapfile -t files < <(find "$folder" -maxdepth 1 -type f 2>/dev/null)

  for file in "${files[@]}"; do
    if [ "$total_deletes" -ge "$target_deletes" ]; then
      break 2
    fi

    delete_file "$file" "$with_delay" "$delay_seconds"

    total_deletes=$((total_deletes + 1))
  done
done

echo "[+] Total delete operations done: $total_deletes"
