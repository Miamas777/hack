#!/bin/bash

# 配置项
TARGET_USER="root"
TARGET_IP="192.168.44.135"
RETRY_COUNT=5
LOG_FILE="/var/log/secure"
TMP_LOG="/tmp/ssh_abnormal_check.log"

echo "====== test abnormal login ======"
echo "target_user: $TARGET_USER"
echo "target_ip: $TARGET_IP"
echo "retry_count: $RETRY_COUNT"

# 清理旧的检测缓存
> "$TMP_LOG"

# 自动触发错误登录
for i in $(seq 1 $RETRY_COUNT); do
    echo -e "\n[$i/$RETRY_COUNT] error login ..."
    sshpass -p "ghy123456" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 $TARGET_USER@$TARGET_IP exit
    sleep 1
done

# 等待日志写入
sleep 2

echo -e "\n====== start detecting abnormal login log ======"

# 解析 secure 日志中的失败记录
grep "Failed password" "$LOG_FILE" | tail -n 20 > "$TMP_LOG"

if [[ -s "$TMP_LOG" ]]; then
    echo "[√] lasted fail login："
    awk '/Failed password/ {
        split($0, a, " ");
        print "time: " a[1], a[2], a[3], "| user: " a[11], "| sourceIP: " a[13];
    }' "$TMP_LOG"
else
    echo "[×] didn't detect abnormal login log, please check sshd config or secure log path"
fi
