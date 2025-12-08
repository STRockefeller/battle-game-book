# 資源管理系統快速測試指南

## 立即測試（無需額外資源）

系統已實作完整的fallback機制，即使沒有任何資源檔案也可以測試基本功能。

### 1. 開啟Godot專案

```
1. 啟動Godot Engine
2. 開啟專案：battle-game-book
3. 等待資源重新匯入（約10-30秒）
```

### 2. 檢查腳本編譯

```
1. 開啟 scripts/AssetManager.gd
2. 檢查是否有錯誤提示
3. 如有錯誤，點選「場景」→「重新載入當前專案」
```

### 3. 執行遊戲

```
1. 點選「執行專案」按鈕（F5）
2. 選擇角色並開始戰鬥
3. 觀察以下效果：
```

#### 預期效果

**✅ 正常運作**：
- 遊戲可以正常啟動
- 戰鬥UI正常顯示
- 角色精靈圖顯示為預設圖示（灰色方塊帶問號）
- 動作可以正常執行
- 戰鬥日誌正常記錄

**⚠️ 預期的警告訊息**：
```
AssetManager: 無法載入資源 'res://assets/sprites/hero/idle.png'，使用預設資源
AssetManager: 無法載入資源 'res://assets/audio/hero/attack.ogg'，使用預設資源
```
這些是正常的，因為實際資源尚未添加。

**❌ 不應該出現的錯誤**：
- 遊戲崩潰
- "AssetManager not found" 錯誤
- "CharacterVisualState not found" 錯誤
- 角色精靈圖完全不顯示

### 4. 測試動畫播放

在戰鬥中執行一個動作（如「重斬」），觀察：
- ✅ 角色精靈圖應該顯示在螢幕上
- ✅ 動作執行時應該有簡單的閃光特效（預設特效）
- ✅ 戰鬥日誌應該記錄動作資訊
- ✅ 動作完成後角色應該回到待機姿態

## 添加測試用資源

### 快速方案：使用簡單的彩色方塊

如果想看到更明顯的效果，可以使用Godot內建工具創建簡單的測試精靈圖：

#### 方法1：使用SVG創建彩色方塊

創建 `assets/sprites/hero/idle.svg`：
```svg
<svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
  <rect width="64" height="64" fill="#4fb1ff"/>
  <text x="32" y="36" font-family="Arial" font-size="10" fill="white" text-anchor="middle">HERO</text>
</svg>
```

創建 `assets/sprites/hero/attack.svg`：
```svg
<svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
  <rect width="64" height="64" fill="#ff4f4f"/>
  <text x="32" y="36" font-family="Arial" font-size="10" fill="white" text-anchor="middle">ATK</text>
</svg>
```

#### 方法2：使用Godot編輯器創建

1. 在Godot中：資源 → 新建 → Image
2. 創建64x64的圖片
3. 使用繪圖工具填充顏色
4. 儲存為PNG

#### 方法3：下載免費素材

1. 前往 [Kenney.nl](https://kenney.nl/assets)
2. 下載 "Pixel Platformer" 或類似資源包
3. 挑選2-3個角色精靈圖
4. 重新命名為 idle.png, attack.png 等
5. 放入對應資料夾

### 最小測試資源集

只需這6個檔案就能看到明顯效果：

```
assets/sprites/hero/idle.png (或.svg)     - 勇者待機
assets/sprites/hero/attack.png           - 勇者攻擊
assets/sprites/elise/idle.png            - 艾莉絲待機
assets/sprites/elise/attack.png          - 艾莉絲攻擊
assets/vfx/actions/slash_hit.tscn        - 攻擊命中特效（可選）
assets/audio/actions/slash_cast.ogg      - 攻擊音效（可選）
```

## 測試特定功能

### 測試1：Fallback機制

```
目的：驗證資源找不到時會使用預設資源

步驟：
1. 不添加任何資源檔案
2. 執行遊戲
3. 開始戰鬥

預期結果：
- 遊戲正常運行
- 角色顯示為預設精靈圖
- 控制台顯示警告但不崩潰
```

### 測試2：精靈圖切換

```
目的：驗證角色姿勢切換時精靈圖會改變

步驟：
1. 添加 hero/idle.png 和 hero/attack.png（使用不同顏色）
2. 執行遊戲並開始戰鬥
3. 執行一個攻擊動作

預期結果：
- 攻擊時角色精靈圖從idle切換到attack
- 動作完成後切換回idle
```

### 測試3：特效播放

```
目的：驗證特效生成和自動清理

步驟：
1. 執行遊戲並開始戰鬥
2. 執行多個攻擊動作
3. 觀察場景樹（F4）

預期結果：
- 每次攻擊都有閃光特效
- 特效播放完畢後自動消失
- 場景樹中不會累積大量特效節點
```

### 測試4：勝利/失敗動畫

```
目的：驗證戰鬥結束時的動畫

步驟：
1. 執行遊戲並開始戰鬥
2. 進行戰鬥直到一方勝利

預期結果：
- 勝利者應顯示勝利姿態（如果有對應精靈圖）
- 失敗者應顯示失敗姿態
- 戰鬥日誌顯示勝利訊息
```

## 除錯技巧

### 如果角色精靈圖不顯示

1. **檢查Sprite2D節點是否存在**
   ```
   在場景樹（F4）中查看是否有 Player1Sprite 和 Player2Sprite
   ```

2. **檢查精靈圖位置**
   ```
   選中Sprite2D節點，查看Inspector中的Position屬性
   預設位置：Player1 (200, 300), Player2 (800, 300)
   ```

3. **檢查精靈圖大小**
   ```
   選中Sprite2D節點，查看Scale屬性
   預設Scale：(2.0, 2.0)
   ```

### 如果遇到編譯錯誤

1. **"AssetManager not found"**
   ```
   解決方案：
   1. 確認 scripts/AssetManager.gd 存在
   2. 點選「場景」→「重新載入當前專案」
   3. 等待重新編譯完成
   ```

2. **"CharacterVisualState not found"**
   ```
   解決方案：同上
   ```

3. **"Invalid get index 'asset_id'"**
   ```
   原因：舊的Character.tres檔案沒有asset_id欄位
   解決方案：
   1. 開啟 resources/characters/Hero.tres
   2. 確認有 asset_id = "hero" 這一行
   3. 儲存檔案
   ```

### 檢視詳細日誌

在Godot控制台中查看詳細資訊：
```
專案 → 專案設定 → Debug → GDScript → Verbose
啟用後會顯示更詳細的錯誤訊息
```

## 效能測試

### 檢查資源快取

執行以下測試腳本（在Godot的Script編輯器中）：
```gdscript
func test_cache():
    var asset_manager = AssetManager.get_instance()
    
    # 第一次載入
    var start_time = Time.get_ticks_msec()
    var sprite1 = asset_manager.load_asset(
        "res://assets/sprites/hero/idle.png",
        AssetManager.AssetType.SPRITE
    )
    var time1 = Time.get_ticks_msec() - start_time
    
    # 第二次載入（應該從快取）
    start_time = Time.get_ticks_msec()
    var sprite2 = asset_manager.load_asset(
        "res://assets/sprites/hero/idle.png",
        AssetManager.AssetType.SPRITE
    )
    var time2 = Time.get_ticks_msec() - start_time
    
    print("第一次載入: %d ms" % time1)
    print("第二次載入: %d ms (快取)" % time2)
    print("快取大小: %d" % asset_manager.get_cache_size())
```

預期結果：第二次載入應該明顯快於第一次

## 下一步

測試成功後，可以：

1. **補充完整資源**
   - 為每個角色添加8種姿勢的精靈圖
   - 為每個動作添加音效和特效
   - 為每個狀態效果添加圖示和特效

2. **優化視覺效果**
   - 調整動畫持續時間
   - 微調特效位置和大小
   - 添加更複雜的粒子效果

3. **擴展功能**
   - 實作角色換裝
   - 添加背景和環境效果
   - 實作戰鬥回放功能

## 需要幫助？

參考以下文檔：
- `assets/docs/AssetManagementSystem.md` - 完整系統文檔
- `assets/docs/AssetSystemImplementationReport.md` - 實作報告
- `assets/sprites/README.md` - 精靈圖指南
- `assets/audio/README.md` - 音效指南
- `assets/vfx/README.md` - 特效指南
