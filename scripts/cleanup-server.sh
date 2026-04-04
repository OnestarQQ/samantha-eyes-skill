#!/bin/bash
# 服务器端自动清理摄像头图片，保留最近200张
DIR="/root/.openclaw/media/inbound/screen-watch"
KEEP=200

count=$(ls -1 "$DIR"/cam_*.jpg 2>/dev/null | wc -l)
if [ "$count" -gt "$KEEP" ]; then
    delete=$((count - KEEP))
    ls -1t "$DIR"/cam_*.jpg | tail -n "$delete" | xargs rm -f
    echo "[$(date '+%Y-%m-%d %H:%M')] 清理了 $delete 张旧图片，保留最近 $KEEP 张"
fi
