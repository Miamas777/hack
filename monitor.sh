#!/bin/bash

# 输出文件路径
OUTPUT_FILE="secAgent_monitor.txt"

# 每次监控间隔（秒）
INTERVAL=60

# 总监控次数（1小时，每分钟一次）
TOTAL_ITERATIONS=60

# 初始化变量
previous_pid=""
iteration=1

# 覆盖旧文件并写入标题
echo "secAgent 进程监控记录（每分钟监控一次，持续1小时）" > "$OUTPUT_FILE"
echo "时间                 PID        状态" >> "$OUTPUT_FILE"
echo "--------------------------------------------" >> "$OUTPUT_FILE"

while [ $iteration -le $TOTAL_ITERATIONS ]; do
    # 当前时间
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # 获取secAgent的PID（排除 grep 本身）
    current_pid=$(ps -ef | grep secAgent | grep -v grep | awk '{print $2}' | head -n 1)

    if [ -z "$current_pid" ]; then
        echo "$timestamp    无进程      [未运行]" >> "$OUTPUT_FILE"
        previous_pid=""
    else
        if [ "$previous_pid" != "" ] && [ "$current_pid" != "$previous_pid" ]; then
            echo "$timestamp    $current_pid      [重启⚠️]" >> "$OUTPUT_FILE"
        else
            echo "$timestamp    $current_pid      [正常]" >> "$OUTPUT_FILE"
        fi
        previous_pid="$current_pid"
    fi

    ((iteration++))
    sleep $INTERVAL
done

echo "监控完成，日志保存在 $OUTPUT_FILE"
