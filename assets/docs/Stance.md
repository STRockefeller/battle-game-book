# Stance

## 姿態（Stance）機制

### 核心概念

姿態是角色當前所處的獨佔性狀態。一個角色在任何時間點都只能有一種姿態。姿態的主要作用是**限制或允許角色可執行的動作**。

### 姿態類型

* **站立（Standing）**：預設姿態。角色可以執行所有基礎動作。
* **倒地（KnockedDown）**：由特定攻擊或技能觸發。此姿態下，角色只能執行如「起身」等有限的動作。
* **滯空（Airborne）**：由「上挑」類技能觸發。此姿態下，角色無法進行任何地面攻擊，但可能允許「空中追擊」等特定動作。
* **防禦（Guarding）**：玩家主動選擇的姿態，大幅提升防禦力，但無法移動或攻擊。

### 遊戲機制特性

* **獨佔性**：當角色獲得新的姿態時，會立即取代舊的姿態。
* **動作過濾**：遊戲的動作選擇介面會根據角色當前的姿態動態更新。如果角色處於「倒地」姿態，動作清單將隱藏所有攻擊和移動動作，只顯示「起身」等相關動作。
* **觸發**：姿態的改變通常由特定的動作或事件觸發（例如，受到強烈打擊導致倒地）。
* **恢復**：某些姿態（如「倒地」）會在其持續時間結束後自動恢復到預設的「站立」姿態。

---

## 與效果系統的區別

姿態系統與效果與異常系統是互補的機制：

| 特性 | 姿態 (Stance) | 效果與異常 (Status Effects) |
| :--- | :--- | :--- |
| **獨佔性** | **獨佔**，角色只能有一種姿態。 | **可疊加**，角色可以擁有多個效果與異常。 |
| **主要功能** | **過濾動作清單**，限制或允許玩家可執行的動作。 | **修正數值與觸發事件**，改變角色戰鬥參數或造成額外影響。 |
| **實現方式** | 程式碼實現（枚舉 + 狀態機） | 混合方案（`.tres` 資源 + 邏輯系統） |

---

## 實現參考

**實現細節參見 DEVELOPMENT_NOTES.md**：姿態系統採用三層架構，包括資源定義層（Stance.gd 枚舉和工具函數）、管理層（StanceManager.gd 狀態轉換和屬性修正）和集成層（Character.gd 便利方法）。具體實現涵蓋姿態類型枚舉、動作篩選邏輯、屬性修正規則和信號系統。

---

## 屬性修正規則

### 防禦狀態 (GUARDING)
- **DEF**: +50（防禦力提升 50%）
- **MDEF**: +25（魔法防禦提升 25%）

### 倒地狀態 (KNOCKED_DOWN)
- **DEF**: -50（防禦力降低 50%）

### 滯空狀態 (AIRBORNE)
- **DEF**: -30（防禦力降低 30%）

### 站立狀態 (STANDING)
- 無修正

---

## 動作權限規則

### 站立 (STANDING)
- 可執行：**所有動作**

### 倒地 (KNOCKED_DOWN)
- 可執行：`stand_up`（起身）
- 不可執行：所有其他動作

### 滯空 (AIRBORNE)
- 可執行：`aerial_attack`、`aerial_skill`（空中動作）
- 不可執行：地面動作

### 防禦 (GUARDING)
- 可執行：`guard`、`counter_guard`（防禦相關動作）
- 不可執行：攻擊和移動動作

---

## 使用方法

### 基礎使用

```gdscript
# 創建角色
var character = Character.new()
character.name = "英雄"

# 改變姿態
character.change_stance(Stance.Type.GUARDING)

# 檢查當前姿態
if character.is_stance(Stance.Type.GUARDING):
	print("角色正在防禦")

# 檢查是否可以執行動作
if character.can_perform_action("attack"):
	# 執行攻擊
	pass
else:
	print("當前姿態無法執行此動作")
```

### 在戰鬥流程中

```gdscript
func execute_turn():
	# 回合開始
	for character in all_characters:
		character.on_turn_start()
	
	# 執行動作
	for action in selected_actions:
		executor = action.executor
		if executor.can_perform_action(action.tag):
			execute_action(action)
		else:
			print("無法執行: 姿態限制")
	
	# 回合結束（姿態持續時間遞減）
	for character in all_characters:
		character.on_turn_end()
```

### 姿態特定的行為

#### 倒地狀態

```gdscript
# 受到強力攻擊時觸發倒地
func take_strong_hit(damage: int):
	character.take_damage(damage)
	
	# 觸發倒地（持續 2 回合）
	if damage > character.max_hp * 0.3:  # 傷害超過 30% HP
		character.change_stance(Stance.Type.KNOCKED_DOWN, 2)

# 倒地時只能起身
if character.is_stance(Stance.Type.KNOCKED_DOWN):
	show_limited_actions(["stand_up"])
```

#### 防禦狀態

```gdscript
# 玩家選擇防禦動作
func perform_guard_action():
	character.change_stance(Stance.Type.GUARDING, 1)
	
	# 防禦力提升 50%
	effective_def = character.get_effective_stat("def")
	print("防禦力臨時提升至: %d" % effective_def)
```

#### 滯空狀態

```gdscript
# 受到上挑攻擊時進入滯空
func perform_uppercut_attack():
	target.change_stance(Stance.Type.AIRBORNE, 1)
	
	# 滯空期間防禦力下降 30%
	# 下一回合只能執行空中動作
```

---

## 常見問題

### Q：姿態何時自動恢復？

A：姿態在回合結束時檢查持續時間。當持續時間歸零時，角色會自動恢復到「站立」姿態。

```gdscript
func on_turn_end() -> void:
	current_stance.on_turn_end()
	if current_stance.is_expired():
		reset_to_standing()
```

### Q：如何讓效果和姿態同時影響屬性？

A：Character 的 `get_effective_stat()` 方法會將效果和姿態的修正值都加起來：

```gdscript
return base_value + effect_modifier + stance_modifier
```

### Q：可以同時擁有多個姿態嗎？

A：不可以。姿態是獨佔的，改變新姿態時會立即替換舊姿態。

### Q：如何在姿態改變時執行特殊邏輯？

A：StanceManager 提供了 `stance_changed` 信號，可以連接回調：

```gdscript
character.stance_manager.stance_changed.connect(_on_stance_changed)

func _on_stance_changed(old_stance: Stance.Type, new_stance: Stance.Type):
	print("姿態從 %s 改變為 %s" % [
		Stance.get_name(old_stance),
		Stance.get_name(new_stance)
	])
```

