# BattleUI 佈局設計文檔

## 概覽

BattleUI 已重新設計為專業的回合制戰鬥 UI，遵循標準的遊戲設計原則，提供清晰的信息層級和易於操作的控制界面。

---

## 佈局結構

### 整體架構

```
┌─────────────────────────────────────────────────────┐
│  Battle (Control)                                   │
├─────────────────────────────────────────────────────┤
│  MainContainer (VBoxContainer)                      │
│  ├─ 【第一層】CharacterStatusPanel (HBoxContainer)  │
│  │  ├─ Player1Panel (角色1 狀態)                    │
│  │  ├─ CenterSpacer                                 │
│  │  └─ Player2Panel (角色2 狀態)                    │
│  │                                                  │
│  ├─ 【第二層】CenterContainer (戰鬥場景區域)        │
│  │                                                  │
│  └─ 【第三層】BottomContainer (HBoxContainer)       │
│     ├─ LogBox (戰鬥日誌)                            │
│     └─ ActionPanel (行動面板)                       │
└─────────────────────────────────────────────────────┘
```

---

## 各部分詳解

### 第一層：角色狀態面板 (CharacterStatusPanel)

**位置**: 螢幕頂部  
**高度**: 120px (固定)  
**功能**: 顯示雙方角色的即時狀態信息

#### Player1Panel (玩家角色)
```
┌─────────────────┐
│    艾莉絲       │  (角色名稱 - 20px 字型)
│ HP: 180 / 180   │  (生命值 - 14px 字型)
│ MP: 180 / 180   │  (魔法值 - 14px 字型)
│ 姿態: 站立      │  (當前姿態 - 12px 字型)
└─────────────────┘
```

**信息內容**:
- 角色名稱
- HP / MaxHP
- MP / MaxMP
- 當前姿態 (站立/倒地/滯空/防禦)
- （可擴展）狀態效果提示

#### Player2Panel (敵方角色)
結構相同，位置在右側

**設計亮點**:
- 使用 PanelContainer 提供視覺區隔
- 兩個面板通過 CenterSpacer 分開，避免擁擠
- MarginContainer 提供內部邊距，內容更舒適

---

### 第二層：戰鬥場景區域 (CenterContainer)

**位置**: 螢幕中央  
**高度**: 佔用剩餘空間的 40%  
**功能**: 展示戰鬥動畫和角色模型（未來擴展）

**當前**: 顯示佔位符文本「【戰鬥場景】」

**未來可添加**:
- 角色立繪
- 攻擊動畫
- 技能視效
- 場景背景

---

### 第三層：底部容器 (BottomContainer)

**位置**: 螢幕底部  
**高度**: 佔用剩餘空間  
**結構**: HBoxContainer，分為兩個主要區域

#### LogBox (戰鬥日誌) - 60% 寬度

```
┌──────────────────────────────┐
│ 【戰鬥日誌】                  │
├──────────────────────────────┤
│ 艾莉絲 使用了「藤蔓鞭打」！   │
│ 對敵人造成 15 傷害！          │
│ 敵人已進入【倒地】狀態！      │
│                              │
│ 敵人 使用了「火焰爆發」！     │
│ 艾莉絲 受到 12 傷害！         │
│ ▼ (自動滾動到最新日誌)       │
└──────────────────────────────┘
```

**特點**:
- RichTextLabel，支持 BBCode 格式化
- 自動滾動跟蹤最新日誌
- 最小尺寸: 400x200px
- 背景使用 PanelContainer

**日誌格式建議**:
```gdscript
# 普通訊息
"角色名 使用了「技能名」！"

# 傷害訊息
"對敵人造成 [color=red]15[/color] 傷害！"

# 狀態變化
"已進入【[color=yellow]倒地[/color]】狀態！"

# 治療
"恢復了 [color=green]20[/color] 生命值！"
```

#### ActionPanel (行動面板) - 35% 寬度

```
┌─────────────────────┐
│ 選擇行動:           │
├─────────────────────┤
│ ▶ 藤蔓鞭打          │
│   消耗: 8 STA       │
│                     │
│ ▶ 精靈箭術          │
│   消耗: 6 STA       │
│                     │
│ ▶ 自然治癒          │
│   消耗: 10 STA      │
│                     │
│ ▶ 召喚藤蔓          │
│   消耗: 12 STA      │
└─────────────────────┘
```

**特點**:
- InstructionLabel: 「選擇行動:」提示
- MovesContainer: 動態生成技能按鈕
- 最小尺寸: 300x200px
- 背景使用 PanelContainer

**技能按鈕內容**:
- 技能名稱
- 消耗資源 (STA/MP)
- 冷卻狀態
- 禁用狀態提示

---

## 色彩和字型方案

### 字型大小
| 用途 | 大小 |
| :--- | :--- |
| 角色名稱 | 20px |
| 狀態數值 (HP/MP) | 14px |
| 姿態信息 | 12px |
| 日誌內容 | 預設 |
| 指令標籤 | 14px |

### 色彩建議

| 元素 | 顏色 | 用途 |
| :--- | :--- | :--- |
| 生命值 (HP) | `#FF4444` (紅色) | 表示重要資源 |
| 魔法值 (MP) | `#4444FF` (藍色) | 表示魔法資源 |
| 耐力值 (STA) | `#FFAA00` (橙色) | 表示體力消耗 |
| 傷害數字 | `#FF0000` (紅色) | 警示性信息 |
| 治療數字 | `#00FF00` (綠色) | 正面效果 |
| 狀態異常 | `#FFFF00` (黃色) | 特殊狀態 |

---

## 響應式設計

### 螢幕尺寸適應

UI 使用 Godot 的錨點系統和相對尺寸，應能適應多種解析度：

- **1920x1080** (推薦): 完整展示所有信息
- **1366x768**: 自動縮小邊距，UI 仍清晰
- **1024x600**: UI 元素可能因空間限制需要調整

### 最小解析度
建議最小解析度: **1024x600**

---

## 交互設計

### 用戶流程

1. **戰鬥開始**
   - 顯示雙方角色狀態
   - 日誌區顯示「戰鬥開始！」

2. **玩家回合**
   - ActionPanel 變為可交互
   - 玩家點擊技能按鈕選擇行動
   - 選擇後按鈕禁用，等待結果

3. **行動解析**
   - LogBox 實時顯示戰鬥過程
   - 角色狀態面板實時更新

4. **敵人回合**
   - ActionPanel 變為不可交互
   - LogBox 顯示敵人的行動

5. **循環**
   - 直到一方 HP ≤ 0

### 按鈕狀態

**可用狀態**:
- 文字正常顯示
- 滑鼠懸停時變亮
- 點擊時反應明顯

**禁用狀態**:
- 文字變灰
- 無法點擊

**冷卻狀態**:
- 顯示冷卻剩餘回合數
- 無法點擊

---

## 實現檢查清單

- [x] 角色狀態面板佈局
- [x] 戰鬥日誌區域佈局
- [x] 行動面板佈局
- [ ] 日誌格式化函數
- [ ] 技能按鈕動態生成
- [ ] 狀態面板實時更新
- [ ] 按鈕狀態管理
- [ ] 顏色主題定義

---

## 使用建議

### 在 Battle.gd 中更新 UI

```gdscript
# 更新角色狀態
func update_character_status(character: Character, panel_name: String):
	var panel = get_node("MainContainer/CharacterStatusPanel/" + panel_name)
	panel.get_node("MarginContainer/VBoxContainer/NameLabel").text = character.name
	panel.get_node("MarginContainer/VBoxContainer/HpLabel").text = "HP: %d / %d" % [character.current_hp, character.max_hp]
	panel.get_node("MarginContainer/VBoxContainer/MpLabel").text = "MP: %d / %d" % [character.current_mp, character.max_mp]
	
	var stance_name = Stance.get_name(character.get_current_stance())
	panel.get_node("MarginContainer/VBoxContainer/StanceLabel").text = "姿態: " + stance_name

# 新增日誌
func add_log(message: String, color: String = "white"):
	var log_box = get_node("MainContainer/BottomContainer/LogBox/MarginContainer/LogContent")
	if color == "white":
		log_box.append_text(message + "\n")
	else:
		log_box.append_text("[color=%s]%s[/color]\n" % [color, message])
	log_box.scroll_to_line(log_box.get_line_count())

# 動態生成技能按鈕
func generate_action_buttons(actions: Array[Action]):
	var moves_container = get_node("MainContainer/BottomContainer/ActionPanel/MarginContainer/VBoxContainer/MovesContainer")
	
	# 清空舊按鈕
	for child in moves_container.get_children():
		child.queue_free()
	
	# 生成新按鈕
	for action in actions:
		var button = Button.new()
		button.text = "%s (STA: %d)" % [action.name, action.cost_stamina]
		button.pressed.connect(func(): _on_action_selected(action))
		moves_container.add_child(button)
```

---

## 下一步

1. 在 Battle.gd 中實現 UI 更新邏輯
2. 測試各種螢幕尺寸的顯示效果
3. 調整邊距和字型大小以優化可讀性
4. 新增視覺效果 (漸變、陰影等)
5. 實現日誌自動卷動和消息隊列
