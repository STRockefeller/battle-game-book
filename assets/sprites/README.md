# 精靈圖資源目錄

此目錄包含遊戲中所有的精靈圖資源。

## 目錄結構

### hero/
勇者角色的精靈圖：
- `idle.png` - 待機姿態
- `attack.png` - 攻擊姿態
- `hit.png` - 受擊姿態
- `defend.png` - 防禦姿態
- `cast.png` - 施法姿態
- `victory.png` - 勝利姿態
- `defeat.png` - 失敗姿態
- `idle_low_hp.png` - 低血量待機姿態

### elise/
艾莉絲角色的精靈圖（結構同上）

### actions/
動作特效精靈圖：
- `hero_slash.png` - 重斬動作
- `vine_lash.png` - 藤蔓鞭打動作
- `guard.png` - 防禦動作
- 等等...

### status_icons/
狀態效果圖示：
- `poison.png` - 中毒圖示
- `burning.png` - 燃燒圖示
- `weakness.png` - 虛弱圖示
- 等等...

## 建議格式

- 格式：PNG（支援透明背景）
- 角色精靈圖建議大小：64x64 到 128x128 像素
- 圖示建議大小：32x32 像素
- 使用透明背景以便靈活使用

## 預設資源

如果某個精靈圖不存在，AssetManager會自動使用預設資源：
- `default_character.png` - 預設角色精靈圖

## 快速開始

1. 將角色精靈圖放入對應的 `hero/` 或 `elise/` 資料夾
2. 確保檔案名稱符合上述命名規範
3. 在 Godot 中重新匯入資源
4. 執行遊戲測試

## 範例資源來源

- [OpenGameArt.org](https://opengameart.org/)
- [Itch.io](https://itch.io/game-assets/free)
- [Kenney.nl](https://kenney.nl/assets)
