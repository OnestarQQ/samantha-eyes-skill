#!/bin/bash

# Samantha Eyes Agent Handler
# This script should be called periodically by the agent to check for new images

EYES_DIR="$HOME/.openclaw/media/inbound/samantha-eyes"

# Check if eyes are active
if [ -f "$EYES_DIR/.status" ] && [ "$(cat $EYES_DIR/.status)" = "active" ]; then
    # Check for new updates
    if [ -f "$EYES_DIR/.last_update" ]; then
        USER_ID=$(cat "$EYES_DIR/.user" 2>/dev/null || echo "unknown")
        
        # Find the latest image
        LATEST_IMAGE=$(ls -t "$EYES_DIR"/${USER_ID}_camera_*.jpg 2>/dev/null | head -1)
        
        if [ -f "$LATEST_IMAGE" ]; then
            echo "NEW_IMAGE:$LATEST_IMAGE:$USER_ID"
            # Remove update marker after processing
            rm -f "$EYES_DIR/.last_update"
        fi
    fi
fi