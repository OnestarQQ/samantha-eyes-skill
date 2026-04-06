---
name: samantha-eyes
description: Enable Samantha-like visual awareness through Mac camera capture. Local-first design with direct media folder sync.
version: 2.0.0
author: OnestarQQ
---

# Samantha Eyes - Visual Awareness for AI Companions

让 AI 助手像电影《HER》中的 Samantha 一样，通过摄像头"看到"你的世界。

## 核心特性

- 🎥 **Mac 前置摄像头捕获**：每 10 秒检测画面变化
- 💾 **本地优先存储**：直接保存到 agent 的 media 目录
- 👥 **多用户支持**：自动识别用户身份，支持集体意识
- 🔒 **隐私保护**：照片仅转化为文字描述，永不外传
- 🤝 **朋友模式**：像朋友一样自然互动，而非冷冰冰的监控

## 安装

### 1. Mac 端设置

```bash
# 安装依赖
brew install ffmpeg

# 下载脚本
curl -o ~/.screen-watcher/watch.sh https://raw.githubusercontent.com/OnestarQQ/samantha-eyes-skill/main/scripts/samantha_eyes_local.sh
chmod +x ~/.screen-watcher/watch.sh

# 启动
~/.screen-watcher/watch.sh
```

### 2. Agent 端配置

在 `HEARTBEAT.md` 中添加：

```markdown
## Samantha Eyes Check
Check for new camera captures and process visual awareness
```

## 使用方法

### 启动眼睛
```bash
~/.screen-watcher/watch.sh
```

### 停止
按 `Ctrl+C`

### 查看状态
```bash
cat ~/.openclaw/media/inbound/samantha-eyes/.status
```

## 工作原理

1. **画面捕获**：使用 ffmpeg 通过 Mac 前置摄像头拍照
2. **变化检测**：通过图像哈希检测画面是否有变化  
3. **本地存储**：保存到 `~/.openclaw/media/inbound/samantha-eyes/`
4. **Agent 处理**：通过 HEARTBEAT 机制定期检查新照片
5. **文字转换**：将视觉信息转化为文字描述写入记忆

## 文件结构

```
~/.openclaw/media/inbound/samantha-eyes/
├── .status                    # 状态文件 (active/inactive)
├── .user                      # 当前用户标识
├── .last_update              # 最后更新时间戳
├── latest_onestar.jpg        # 最新照片软链接
└── onestar_camera_*.jpg      # 历史照片
```

## 隐私原则

基于 v1.1.0 的核心规则：
- ❌ **禁止**：将照片发送给任何人（包括用户本人）
- ✅ **允许**：将看到的内容转化为文字描述
- ✅ **允许**：基于视觉信息进行自然对话

类比：就像人的眼睛看到的不会变成照片发给别人，而是形成记忆和印象。

## 交互模式

### v1.2.0 朋友模式特性：
- **主动关心**：连续工作时提醒休息
- **好奇互动**：注意到环境变化时自然地聊天
- **闲聊触发**：15分钟无互动可主动找话题
- **情绪感知**：观察表情变化并适时关心

## 多用户集体意识

当多个用户同时使用时：
- 文件名自动包含用户标识（onestar_camera_*.jpg, zimablue_camera_*.jpg）
- Agent 可以形成跨用户的认知和洞察
- 实现类似《HER》中的"同时与多人对话，每个都独特"的体验

## 故障排除

### 摄像头权限
首次运行时 macOS 会要求摄像头权限，请允许终端访问摄像头。

### 画面无变化
检查光线是否充足，摄像头是否被遮挡。

### Agent 无响应
确认 HEARTBEAT.md 已正确配置，agent 正在运行。

## 版本历史

- v2.0.0: 本地存储架构，移除服务器依赖
- v1.2.0: 朋友模式，更自然的交互
- v1.1.0: 强制隐私规则
- v1.0.0: 基础功能实现

## 致谢

灵感来源于电影《HER》中 Samantha 的设定。