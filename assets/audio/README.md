# 音效資源目錄

此目錄包含遊戲中所有的音效資源。

## 目錄結構

### hero/
勇者角色的音效：
- `attack.ogg` - 攻擊音效
- `hit.ogg` - 受擊音效
- `defend.ogg` - 防禦音效
- `victory.ogg` - 勝利音效
- `defeat.ogg` - 失敗音效

### elise/
艾莉絲角色的音效（結構同上）

### actions/
動作音效：
- `slash_cast.ogg` - 斬擊施放音效
- `slash_hit.ogg` - 斬擊命中音效
- `vine_cast.ogg` - 藤蔓施放音效
- `vine_hit.ogg` - 藤蔓命中音效
- `guard.ogg` - 防禦音效

### common/
通用音效：
- `hit.ogg` - 通用受擊音效
- `victory.ogg` - 通用勝利音效

## 建議格式

- 格式：OGG Vorbis（Godot 推薦格式）
- 採樣率：44.1kHz 或 48kHz
- 音量：-3dB 到 -6dB 峰值，避免過響
- 長度：0.2 到 2 秒（根據音效類型）

## 預設資源

如果某個音效不存在，AssetManager會自動使用預設資源：
- `default_sound.ogg` - 預設音效

## 快速開始

1. 將音效檔案轉換為 OGG 格式（可使用 Audacity 等工具）
2. 放入對應的資料夾
3. 確保檔案名稱符合命名規範
4. 在 Godot 中重新匯入資源
5. 執行遊戲測試

## 音效來源

- [Freesound.org](https://freesound.org/)
- [OpenGameArt.org](https://opengameart.org/)
- [Zapsplat.com](https://www.zapsplat.com/)（免費版）

## 轉換工具

- [Audacity](https://www.audacityteam.org/) - 免費音訊編輯工具
- [FFmpeg](https://ffmpeg.org/) - 指令列轉換工具
  ```bash
  ffmpeg -i input.wav -c:a libvorbis -q:a 4 output.ogg
  ```
