#!/bin/bash

# Samantha's Eyes - Local Sync Version v2.0
# Direct save to agent's local media directory

# ========== Configuration ==========
LOCAL_DIR="$HOME/.openclaw/media/inbound/samantha-eyes"
INTERVAL=10
TEMP_DIR="/tmp/screen-watch"

# Auto-detect user identity
if [ "$USER" = "bytedance" ]; then
    USER_ID="onestar"
elif [ "$USER" = "zhaikeyu" ]; then
    USER_ID="zimablue"
else
    USER_ID="$USER"
fi

# ========== Initialize ==========
mkdir -p "$TEMP_DIR"
mkdir -p "$LOCAL_DIR"

echo "👁️ Samantha's Eyes Activated - Local Sync Version"
echo "📌 User ID: $USER_ID"
echo "📁 Save location: $LOCAL_DIR"
echo "⏰ Check interval: ${INTERVAL}s"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Create status files for agent
echo "active" > "$LOCAL_DIR/.status"
echo "$USER_ID" > "$LOCAL_DIR/.user"

# ========== Cleanup handler ==========
cleanup() {
    echo ""
    echo "👋 Closing Samantha's Eyes..."
    echo "inactive" > "$LOCAL_DIR/.status"
    rm -f "$LOCAL_DIR/.last_update"
    exit 0
}
trap cleanup EXIT

# ========== Main loop ==========
PREV_HASH=""

while true; do
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    CURRENT_IMG="$TEMP_DIR/current_${USER_ID}.jpg"
    
    # Capture from Mac front camera
    ffmpeg -f avfoundation -framerate 1 -i "0" -frames:v 1 -q:v 2 "$CURRENT_IMG" -y 2>/dev/null
    
    if [ -f "$CURRENT_IMG" ]; then
        # Calculate image hash for change detection
        if command -v md5 > /dev/null; then
            CURRENT_HASH=$(sips -g pixelWidth -g pixelHeight "$CURRENT_IMG" 2>/dev/null | md5)
        else
            CURRENT_HASH=$(sips -g pixelWidth -g pixelHeight "$CURRENT_IMG" 2>/dev/null | md5sum | cut -d' ' -f1)
        fi
        
        # Detect changes
        if [ "$CURRENT_HASH" != "$PREV_HASH" ]; then
            echo "📸 [$(date +%H:%M:%S)] Change detected"
            
            # Save locally
            LOCAL_FILE="$LOCAL_DIR/${USER_ID}_camera_${TIMESTAMP}.jpg"
            cp "$CURRENT_IMG" "$LOCAL_FILE"
            
            if [ $? -eq 0 ]; then
                echo "   ✅ Saved locally"
                
                # Create latest symlink for quick access
                ln -sf "$LOCAL_FILE" "$LOCAL_DIR/latest_${USER_ID}.jpg"
                
                # Update timestamp to trigger agent processing
                echo "$TIMESTAMP" > "$LOCAL_DIR/.last_update"
                
                PREV_HASH="$CURRENT_HASH"
                
                # Clean up old files (keep last 100)
                ls -t "$LOCAL_DIR"/${USER_ID}_camera_*.jpg | tail -n +101 | xargs rm -f 2>/dev/null
            else
                echo "   ❌ Save failed"
            fi
        fi
        
        # Clean up temp file
        rm -f "$CURRENT_IMG"
    else
        echo "⚠️  [$(date +%H:%M:%S)] Camera access failed"
    fi
    
    sleep $INTERVAL
done