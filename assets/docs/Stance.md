# Stance

### 姿態（Stance）機制

**核心概念**：姿態是角色當前所處的獨佔性狀態。一個角色在任何時間點都只能有一種姿態。姿態的主要作用是**限制或允許角色可執行的動作**。

**類型範例**：
* **站立（Standing）**：預設姿態。角色可以執行所有基礎動作。
* **倒地（KnockedDown）**：由特定攻擊或技能觸發。此姿態下，角色只能執行如「起身」等有限的動作。
* **滯空（Airborne）**：由「上挑」類技能觸發。此姿態下，角色無法進行任何地面攻擊，但可能允許「空中追擊」等特定動作。
* **防禦（Guarding）**：玩家主動選擇的姿態，大幅提升防禦力，但無法移動或攻擊。

**遊戲機制**：
* **獨佔性**：當角色獲得新的姿態時，會立即取代舊的姿態。
* **動作過濾**：遊戲的動作選擇介面會根據角色當前的姿態動態更新。如果角色處於「倒地」姿態，動作清單將隱藏所有攻擊和移動動作，只顯示「起身」等相關動作。
* **觸發**：姿態的改變通常由特定的動作或事件觸發（例如，受到強烈打擊導致倒地）。
* **恢復**：某些姿態（如「倒地」）會在其持續時間結束後自動恢復到預設的「站立」姿態。

---

## 設計考量

### 與效果系統的區別

姿態系統與效果與異常系統是互補的機制：

| 特性 | 姿態 (Stance) | 效果與異常 (Status Effects) |
| :--- | :--- | :--- |
| **獨佔性** | **獨佔**，角色只能有一種姿態。 | **可疊加**，角色可以擁有多個效果與異常。 |
| **主要功能** | **過濾動作清單**，限制或允許玩家可執行的動作。 | **修正數值與觸發事件**，改變角色戰鬥參數或造成額外影響。 |
| **實現方式** | 程式碼實現（枚舉 + 狀態機） | 混合方案（`.tres` 資源 + 邏輯系統） |

透過這兩個獨立但互補的系統，你可以更靈活地設計遊戲中的各種狀態，從而創造出更豐富、更具策略性的戰鬥體驗。

---

## 實現方向

姿態系統建議採用**程式碼實現**，而非資源方式：

```gdscript
class_name Character extends Resource

enum StanceType { STANDING, KNOCKED_DOWN, AIRBORNE, GUARDING }

var current_stance: StanceType = StanceType.STANDING
var stance_duration: int = 0  # 姿態持續時間

func change_stance(new_stance: StanceType, duration: int = -1) -> void:
	current_stance = new_stance
	stance_duration = duration
	_update_available_actions()

func _update_available_actions() -> void:
	# 根據當前姿態過濾可用動作
	match current_stance:
		StanceType.KNOCKED_DOWN:
			# 只允許「起身」等特定動作
			pass
		StanceType.AIRBORNE:
			# 只允許「空中追擊」等特定動作
			pass
		# ...
```

這樣的設計保持了邏輯的清晰性和性能的最優化。
