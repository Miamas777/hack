#!/bin/bash

# ====== 模块开关 ======
enable_read=true
enable_write=true
enable_chmod=true
enable_rename=true
enable_delete=true

# ====== 参数设置 ======
delay_seconds=1           # 操作间隔秒数
with_delay=true           # 是否启用间隔
target_total=10           # 每个模块最多处理文件数

# ====== 已处理文件记录表 ======
declare -A used_files     # 记录已经被使用过的文件（路径作为 key）

# ====== 读取模块 ======
read_file() {
  local file="$1"
  echo "    [READ] $file"
  cat "$file" > /dev/null
  [ "$with_delay" == "true" ] && sleep "$delay_seconds"
}

# ====== 写入模块 ======
write_file() {
  local file="$1"
  echo "    [WRITE] $file"
  echo "Modified on $(date)" >> "$file"
  [ "$with_delay" == "true" ] && sleep "$delay_seconds"
}

# ====== 权限修改模块 ======
chmod_file() {
  local file="$1"
  echo "    [CHMOD] $file"
  chmod 600 "$file"
  [ "$with_delay" == "true" ] && sleep "$delay_seconds"
}

# ====== 重命名模块 ======
rename_file() {
  local file="$1"
  local index="$2"
  local dir ext new_name
  dir=$(dirname "$file")
  ext="${file##*.}"
  new_name="${dir}/${index}.${ext}"
  echo "    [RENAME] $file -> $new_name"
  mv "$file" "$new_name"
  [ "$with_delay" == "true" ] && sleep "$delay_seconds"
}

# ====== 删除模块 ======
delete_file() {
  local file="$1"
  echo "    [DELETE] $file"
  rm -f "$file"
  [ "$with_delay" == "true" ] && sleep "$delay_seconds"
}

# ====== 主流程函数 ======
perform_operation() {
  local op_func=$1
  local op_label=$2
  local -n counter=$3
  local -n exclude_map=$4

  for folder in "${folders[@]}"; do
    mapfile -t files < <(find "$folder" -maxdepth 1 -type f 2>/dev/null)
    for file in "${files[@]}"; do
      if [ "${used_files[$file]}" == "true" ]; then
        continue
      fi
      if [ "$counter" -ge "$target_total" ]; then
        return
      fi

      $op_func "$file"
      used_files["$file"]="true"
      exclude_map["$file"]="true"
      counter=$((counter + 1))
    done
  done
}

# ====== 初始化 zzz* 文件夹列表 ======
mapfile -t folders < <(find / -type d -name "zzz*" 2>/dev/null)

# ====== 操作执行 ======

read_count=0
write_count=0
chmod_count=0
rename_count=0
delete_count=0

declare -A read_files
declare -A write_files
declare -A chmod_files
declare -A rename_files
declare -A delete_files

echo "[*] Starting bait file operation testing..."

$enable_read   && perform_operation read_file   "READ"   read_count   read_files
$enable_write  && perform_operation write_file  "WRITE"  write_count  write_files
$enable_chmod  && perform_operation chmod_file  "CHMOD"  chmod_count  chmod_files
$enable_rename && perform_operation rename_file "RENAME" rename_count rename_files
$enable_delete && perform_operation delete_file "DELETE" delete_count delete_files

echo "[*] All selected operations completed."
echo "    Total READ:   $read_count"
echo "    Total WRITE:  $write_count"
echo "    Total CHMOD:  $chmod_count"
echo "    Total RENAME: $rename_count"
echo "    Total DELETE: $delete_count"
