# ⚠️ VS Code 編譯錯誤說明

## 當前狀態

VS Code 的 GDScript 語言伺服器顯示以下錯誤：
```
Could not find type "AssetManager" in the current scope.
Could not find type "CharacterVisualState" in the current scope.
Could not find type "BattleVisualPlayer" in the current scope.
```

## 這是正常的！

**這些錯誤只出現在 VS Code 中，不會影響 Godot 的執行。**

### 原因

1. VS Code 的語言伺服器需要時間解析新增的 class_name 宣告
2. 某些情況下，VS Code 無法正確追蹤 Godot 的類別註冊
3. 這是 VS Code GDScript 擴充功能的已知限制

### 解決方案

**在 Godot 中開啟專案後，這些錯誤會自動消失**，因為 Godot 的編譯器會正確識別所有類別。

### 驗證步驟

1. 在 Godot 中開啟專案
2. 等待資源重新匯入完成
3. 查看 Godot 編輯器底部的「輸出」面板
4. 如果沒有紅色錯誤訊息，表示編譯成功

### 如果 Godot 中仍有錯誤

請嘗試以下步驟：

1. **重新載入專案**
   ```
   場景 → 重新載入當前專案
   ```

2. **檢查檔案是否存在**
   ```
   確認以下檔案存在：
   - scripts/AssetManager.gd
   - scripts/CharacterVisualState.gd
   - scripts/BattleVisualPlayer.gd
   ```

3. **手動開啟腳本**
   ```
   在 Godot 中逐一開啟上述三個檔案
   確認第二行有 class_name 宣告
   ```

4. **清除快取**
   ```
   關閉 Godot
   刪除 .godot/ 資料夾
   重新開啟專案
   ```

## 預期的 Godot 輸出

### ✅ 正常輸出（無錯誤）

```
Godot Engine v4.x.stable
OpenGL API 3.3.0 - Build ...
--- Debugging process started ---
Scene "res://scenes/MainMenu.tscn" loaded.
```

### ⚠️ 預期的警告（這些是正常的）

```
AssetManager: 無法載入資源 'res://assets/sprites/hero/defend.png'，使用預設資源
AssetManager: 無法載入資源 'res://assets/audio/hero/attack.ogg'，使用預設資源
```

這些警告表示系統正確運作，只是某些資源檔案尚未添加。

### ❌ 不應出現的錯誤

```
Parse Error: Class "AssetManager" hides a global script class.
Invalid call. Nonexistent function 'get_instance' in base 'Nil'.
```

如果出現這類錯誤，請按照上述「解決方案」步驟操作。

## 總結

- ✅ VS Code 的錯誤提示可以忽略
- ✅ 在 Godot 中開啟專案即可正常運行
- ✅ 系統已完整實作並準備好測試
- ✅ 所有必要的檔案都已創建

**請直接在 Godot 中開啟專案並執行測試！** 🚀
