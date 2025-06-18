#!/bin/bash

# 重命名函数
# 参数1：文件路径
# 参数2：当前序号
# 参数3：是否启用间隔（true/false）
# 参数4：间隔秒数（默认1秒）
rename_file() {
  local file="$1"
  local index="$2"
  local with_delay="$3"
  local delay=${4:-1}

  local dir
  local ext
  local new_name

  dir=$(dirname "$file")
  ext="${file##*.}"
  new_name="${dir}/${index}.${ext}"

  echo "    [*] Renaming: $file -> $new_name"

  mv "$file" "$new_name"

  if [ "$with_delay" == "true" ]; then
    sleep "$delay"
  fi
}

# ------------主流程--------------

total_renamed=0
target_renamed=10
with_delay=false       # 是否启用间隔重命名
delay_seconds=1        # 间隔秒数

# 找所有以 zzz 开头的目录
mapfile -t folders < <(find / -type d -name "zzz*" 2>/dev/null)

for folder in "${folders[@]}"; do
  if [ "$total_renamed" -ge "$target_renamed" ]; then
    break
  fi

  echo "[+] Processing folder: $folder"

  mapfile -t files < <(find "$folder" -maxdepth 1 -type f 2>/dev/null)

  for file in "${files[@]}"; do
    if [ "$total_renamed" -ge "$target_renamed" ]; then
      break 2
    fi

    index=$((total_renamed + 1))
    rename_file "$file" "$index" "$with_delay" "$delay_seconds"

    total_renamed=$((total_renamed + 1))
  done
done

echo "[+] Total rename operations done: $total_renamed"
