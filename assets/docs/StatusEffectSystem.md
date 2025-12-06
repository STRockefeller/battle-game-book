# 狀態效果系統

## 效果與異常（Status Effects）機制

### 核心概念

效果與異常是作用於角色的非獨佔性狀態，可以同時存在並疊加。它們的主要作用是**影響角色的屬性數值或在特定時間觸發額外事件**。

### 分類

* **增益效果（Buffs）**：例如「亢奮」，提升角色攻擊力與敏捷。
* **減益效果（Debuffs）**：例如「虛弱」，降低角色攻擊力與防禦力。
* **異常狀態（Ailments）**：例如「中毒」，每回合造成持續傷害；「麻痺」，有一定機率使角色行動失敗。

### 機制特性

* **疊加性**：一個角色可以同時受到多個效果與異常的影響。
* **數值影響**：通過「屬性修正值」直接修改角色的戰鬥參數。
* **生命週期**：每個效果有獨立的持續時間，回合制中通常在回合結束時遞減。
* **觸發時機**：某些效果在特定時間點觸發（如「中毒」在回合結束時造成傷害）。
* **移除機制**：效果在持續時間歸零時自動移除，或被「驅散」類動作移除。

---

## 系統架構

新的狀態效果系統採用**混合方案**，分為三個主要部分：

### 1. StatusEffect.gd（資源類 - 純數據）
- **用途**：定義狀態效果的**靜態數據**
- **特點**：只包含屬性，不包含任何邏輯
- **位置**：`scripts/character/status_effect/StatusEffect.gd`

### 2. StatusEffectManager.gd（管理系統 - 邏輯層）
- **用途**：管理角色身上的所有狀態效果
- **特點**：處理應用、移除、查詢、觸發效果
- **位置**：`scripts/character/status_effect/StatusEffectManager.gd`

**主要函數**：
```gdscript
apply_effect(effect: StatusEffect)      # 應用效果
remove_effect(effect_id: String)        # 移除效果
has_effect(effect_id: String) -> bool   # 檢查效果
get_effect(effect_id: String)           # 獲取效果
on_turn_start()                         # 回合開始時調用
on_turn_end()                           # 回合結束時調用
```

### 3. StatusEffectHandlers.gd（效果實現 - 邏輯層）
- **用途**：實現具體的效果觸發邏輯
- **特點**：針對不同的效果類型有不同的處理函數
- **位置**：`scripts/character/status_effect/StatusEffectHandlers.gd`

**支持的效果類型**：
```
- poison: 每回合造成傷害
- burning: 每回合造成傷害
- weakness: 降低攻擊力（通過 stat_modifiers）
- stun: 禁止行動
- regen: 每回合恢復生命值
```

---

## 工作流程

### 創建新的狀態效果

#### 步驟 1：在編輯器中創建 `.tres` 資源

1. 在 `resources/statuses/` 文件夾中右鍵 → 新建資源
2. 選擇資源類型：`StatusEffect`
3. 保存為合適的名稱（例如 `Poison.tres`）

#### 步驟 2：配置資源屬性

**示例 1 - 中毒效果（每回合造成傷害）**：
```
effect_type: "poison"
id: "poison"
name: "中毒"
description: "每回合損失 5 HP"
duration: 3
is_debuff: true
triggers_on_turn_end: true
effect_parameters: { "damage_per_turn": 5 }
stat_modifiers: {}
```

**示例 2 - 虛弱效果（降低屬性）**：
```
effect_type: "weakness"
id: "weakness"
name: "虛弱"
description: "攻擊力降低 5"
duration: 2
is_debuff: true
triggers_on_turn_end: false
effect_parameters: {}
stat_modifiers: { "atk": -5 }
```

**示例 3 - 再生效果（恢復生命值）**：
```
effect_type: "regen"
id: "regen"
name: "再生"
description: "每回合恢復 8 HP"
duration: -1          # -1 表示永久
is_debuff: false
triggers_on_turn_end: true
effect_parameters: { "recovery_per_turn": 8 }
stat_modifiers: {}
```

#### 步驟 3：實現效果邏輯（如需要）

如果是標準的「造成傷害」或「修正屬性」效果，可以使用現有的處理器。

如果是自定義效果，需要在 `StatusEffectHandlers.gd` 中添加新的處理函數。

---

## 使用方法

### 在角色上應用效果

```gdscript
# 加載效果資源
var poison_effect = load("res://resources/statuses/Poison.tres")

# 應用到角色
character.apply_effect(poison_effect)
```

### 在戰鬥流程中觸發效果

```gdscript
# 在回合開始時
character.on_turn_start()

# 在回合結束時
character.on_turn_end()
```

### 查詢和管理效果

```gdscript
# 檢查是否有特定效果
if character.effect_manager.has_effect("poison"):
    print("角色中毒了！")

# 獲取所有負面效果
var debuffs = character.effect_manager.get_all_debuffs()

# 移除特定效果
character.remove_effect("poison")

# 獲取屬性修正值
var attack_modifier = character.effect_manager.get_stat_modifier("atk")
var effective_atk = character.get_effective_stat("atk")
```

---

## 如何添加新效果類型

### 第 1 步：定義效果資源

在 `resources/statuses/` 中創建新的 `.tres` 檔案，設置合適的 `effect_type`。

### 第 2 步：在 StatusEffectHandlers.gd 中添加處理函數

```gdscript
# 在 trigger_effect() 中添加新的 match 分支
match effect.effect_type:
    "new_effect":
        _trigger_new_effect(character, effect)

# 實現具體的處理函數
static func _trigger_new_effect(character: Character, effect: StatusEffect) -> void:
    var param = effect.effect_parameters.get("param_name", default_value)
    # 實現效果邏輯
    pass
```

### 第 3 步：測試效果

在戰鬥場景中測試新效果是否正確觸發和應用。

---

## 設計原則

### 資源層職責（`.tres` 文件）
- ✓ 定義靜態數據（屬性、參數、持續時間）
- ✗ 不包含任何邏輯代碼

### 邏輯層職責（`.gd` 文件）
- ✓ 處理複雜的狀態轉換
- ✓ 實現條件判定
- ✓ 管理效果的應用和移除
- ✓ 在適當的時機觸發效果

### 優勢
1. **低複雜度**：資源只需定義數據，邏輯保留在代碼中
2. **易於擴展**：新增效果只需創建新的 `.tres` 檔案
3. **高效能**：邏輯清晰，便於優化
4. **易於維護**：清晰的職責分界

---

## 常見問題

### Q：為什麼不在 .tres 中定義所有邏輯？

A：`.tres` 是靜態資源格式，無法存儲和執行代碼邏輯。將邏輯分離到代碼中可以：
- 實現複雜的條件判定
- 處理副作用和狀態轉換
- 便於調試和測試

### Q：如何讓一個效果根據條件有不同的表現？

A：使用 `effect_parameters` 字典存儲條件參數，在 `StatusEffectHandlers` 中讀取並判定：

```gdscript
static func _trigger_custom_effect(character: Character, effect: StatusEffect) -> void:
    var condition = effect.effect_parameters.get("condition", "default")
    match condition:
        "type_a":
            # 特定行為
            pass
        "type_b":
            # 另一種行為
            pass
```

### Q：如何讓效果之間相互影響？

A：在 `StatusEffectHandlers` 中檢查角色的其他效果：

```gdscript
static func _trigger_synergy_effect(character: Character, effect: StatusEffect) -> void:
    if character.effect_manager.has_effect("another_effect"):
        # 如果同時擁有另一個效果，執行增強邏輯
        pass
```

---

## 待實現的功能

1. **免疫系統**：某些角色或姿態可能對特定效果免疫
2. **效果疊加規則**：是否允許同一效果疊加，如何處理
3. **效果優先度**：某些效果可能覆蓋其他效果
4. **效果觸發條件**：根據角色狀態或環境條件來決定是否應用效果
