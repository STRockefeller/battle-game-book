# 預設音效檔案

由於 GitHub Copilot 無法生成真實的音訊檔案，您需要自行添加一個預設音效檔案。

## 建立方式

### 方法 1: 使用 Audacity 生成靜音檔
1. 開啟 Audacity
2. 生成 → 靜音 → 0.1 秒
3. 檔案 → 匯出 → 匯出為 OGG
4. 另存為 `default_sound.ogg`

### 方法 2: 下載免費音效
1. 前往 [Freesound.org](https://freesound.org/)
2. 搜尋 "pop" 或 "click"
3. 下載並轉換為 OGG 格式
4. 重新命名為 `default_sound.ogg`

### 方法 3: 使用 FFmpeg 生成
```bash
ffmpeg -f lavfi -i "sine=frequency=440:duration=0.1" -c:a libvorbis default_sound.ogg
```

將生成的檔案放在此位置：
`assets/audio/default_sound.ogg`

## 臨時解決方案

如果沒有音效檔案，AssetManager 會在找不到音效時使用 null，遊戲仍可正常運行（只是沒有音效）。
