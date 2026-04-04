#!/bin/bash
# 🌟 萨曼莎的眼睛 - Mac端一键安装
# 用法：bash install-mac.sh <服务器IP> <SSH密钥路径>
# 示例：bash install-mac.sh 124.156.197.81 ~/.ssh/samantha_key

set -e

SERVER_IP="${1:-124.156.197.81}"
KEY_PATH="${2:-$HOME/.ssh/samantha_key}"

DIR="$HOME/.screen-watcher"
REMOTE_DIR="/root/.openclaw/media/inbound/screen-watch"

echo ""
echo "🌟 萨曼莎的眼睛 - 安装中..."
echo ""

# 检查依赖
echo "📌 检查依赖..."
command -v ffmpeg >/dev/null 2>&1 || { echo "❌ 需要ffmpeg: brew install ffmpeg"; exit 1; }
echo "   ✅ ffmpeg"
command -v scp >/dev/null 2>&1 || { echo "❌ 需要scp"; exit 1; }
echo "   ✅ scp"

if [ ! -f "$KEY_PATH" ]; then
    echo "❌ SSH密钥不存在: $KEY_PATH"
    echo "   请先配置SSH密钥登录"
    exit 1
fi
echo "   ✅ SSH密钥: $KEY_PATH"

# 测试连接
echo ""
echo "📌 测试SSH连接..."
if ssh -i "$KEY_PATH" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "root@${SERVER_IP}" "echo ok" >/dev/null 2>&1; then
    echo "   ✅ 连接成功"
else
    echo "   ❌ 连接失败，检查网络和SSH密钥"
    exit 1
fi

# 创建服务器端目录
ssh -i "$KEY_PATH" "root@${SERVER_IP}" "mkdir -p ${REMOTE_DIR}" 2>/dev/null

# 写入监控脚本
mkdir -p "$DIR/frames"

cat > "$DIR/watch.sh" << WATCHEOF
#!/bin/bash
SERVER_KEY="${KEY_PATH}"
SERVER="root@${SERVER_IP}"
REMOTE_DIR="${REMOTE_DIR}"
DIR="\$HOME/.screen-watcher/frames"
INTERVAL=5
PREV_FILE=""
FRAME=0
SENT=0

mkdir -p "\$DIR"

echo ""
echo "🌟 萨曼莎的眼睛已启动（摄像头模式）"
echo "   每\${INTERVAL}秒拍一张，画面变化才发送"
echo "   按 Ctrl+C 停止"
echo ""

cleanup() { echo ""; echo "👋 已停止。共拍\${FRAME}帧，发送\${SENT}帧"; exit 0; }
trap cleanup INT TERM

get_hash() {
    sips -z 16 16 "\$1" --out "\$DIR/thumb.jpg" -s formatOptions low >/dev/null 2>&1
    md5 -q "\$DIR/thumb.jpg" 2>/dev/null
    rm -f "\$DIR/thumb.jpg"
}

while true; do
    FRAME=\$((FRAME + 1))
    TS=\$(date '+%Y%m%d_%H%M%S')
    CURRENT="\$DIR/frame_\${TS}.jpg"

    ffmpeg -f avfoundation -video_size 1280x720 -framerate 30 -i "0:none" \
        -frames:v 1 -q:v 5 -y "\$CURRENT" -loglevel quiet 2>/dev/null

    if [ ! -f "\$CURRENT" ]; then
        echo "⚠️  拍照失败！系统设置→隐私与安全性→摄像头→勾选终端"
        sleep \$INTERVAL; continue
    fi

    SEND=false
    if [ -z "\$PREV_FILE" ] || [ ! -f "\$PREV_FILE" ]; then
        SEND=true
    else
        H1=\$(get_hash "\$PREV_FILE"); H2=\$(get_hash "\$CURRENT")
        [ "\$H1" != "\$H2" ] && SEND=true
    fi

    if \$SEND; then
        SIZE=\$(du -k "\$CURRENT" | cut -f1); SENT=\$((SENT + 1))
        scp -i "\$SERVER_KEY" -q "\$CURRENT" "\${SERVER}:\${REMOTE_DIR}/cam_\${TS}.jpg" 2>/dev/null &
        echo "📸 [\$(date '+%H:%M:%S')] 画面变化 (\${SIZE}KB) → 已发送 #\${SENT}"
        PREV_FILE="\$CURRENT"
    else
        rm -f "\$CURRENT"
        printf "\r⏳ [帧:%d 发送:%d] %s 无变化   " \$FRAME \$SENT "\$(date '+%H:%M:%S')"
    fi

    [ \$((FRAME % 50)) -eq 0 ] && ls -1t "\$DIR"/frame_*.jpg 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null

    sleep \$INTERVAL
done
WATCHEOF

chmod +x "$DIR/watch.sh"

echo ""
echo "✅ 安装完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  启动：~/.screen-watcher/watch.sh"
echo "  停止：Ctrl+C"
echo "  卸载：rm -rf ~/.screen-watcher"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  首次运行macOS会弹窗要求摄像头权限，点允许！"
echo ""

read -p "现在启动吗？(y/n) " yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ] || [ "$yn" = "" ]; then
    exec "$DIR/watch.sh"
fi
