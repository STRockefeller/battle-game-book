# Stat Modifier System（屬性修正器系統）

## 概述

Stat Modifier 系統用於管理戰鬥中的**動態屬性修正**，例如：
- **被動特質**（Passive Traits）提供的加成
- **神恩**（Divine Blessings）賦予的力量
- **姿態**（Stance）觸發的條件性效果

## 核心組件

### StatModifier（屬性修正器）
- 檔案：`StatModifier.gd`
- 功能：定義單個屬性修正操作
- 屬性：
  - `property`: 修正的屬性（如 `damage_bonus`, `critical_rate`）
  - `operation`: 操作類型（`add`, `multiply`, `replace`）
  - `value`: 修正值
  - `tags_filter`: 標籤過濾（限定作用於特定行動類型）

### ModifierGroup（修正器組）
- 檔案：`ModifierGroup.gd`
- 功能：將多個修正器組合，支持條件觸發和持續時間
- 屬性：
  - `modifiers: Array[StatModifier]`: 包含的修正器
  - `condition: ModifierCondition`: 觸發條件
  - `duration`: 持續時間（-1 為永久）
  - `source`: 來源標識（`passive`, `divine`, `stance`）

### ModifierCondition（修正器條件）
- 檔案：`ModifierCondition.gd`
- 功能：定義修正器的觸發條件
- 支持條件：
  - HP 百分比範圍
  - 角色姿態
  - 行動標籤
  - 對手狀態
  - 回合數範圍

### StatModifierManager（修正器管理器）
- 檔案：`StatModifierManager.gd`
- 功能：集中管理所有活躍的修正器組
- 主要方法：
  - `add_group()`: 添加修正器組
  - `apply_modifiers()`: 計算屬性的最終修正值
  - `tick()`: 更新持續時間，移除過期效果

## 與 StatusEffect 的區別

| 特性 | StatModifier | StatusEffect |
|------|--------------|--------------|
| **用途** | 計算時的屬性修正 | 持續性戰鬥狀態 |
| **來源** | 被動特質、神恩 | 行動施加的效果 |
| **生命週期** | 通常永久或戰鬥期間 | 有限回合數 |
| **觸發時機** | 計算傷害/資源時 | 回合開始/結束時 |
| **示例** | +25%物理傷害、-20%耐力消耗 | 中毒（每回合扣血）、虛弱（降低攻擊） |

## 使用示例

### 創建被動特質
```gdscript
var trait = PassiveTrait.new("brute_force", "蠻力", "物理傷害 +25%")
trait.modifiers = [
    StatModifier.new("damage_bonus", "add", 0.25, ["physical"])
]
var group = trait.to_group()
modifier_manager.add_group(group)
```

### 應用條件性修正
```gdscript
# 低血量時傷害加成
var condition = ModifierCondition.new()
condition.required_hp_range = Vector2(0, 0.3)

var trait = PassiveTrait.new("last_stand", "背水一戰", "HP < 30% 時傷害 +20%")
trait.modifiers = [StatModifier.new("damage_bonus", "add", 0.20)]
trait.conditions = [condition]
```

### 在戰鬥中應用修正
```gdscript
# 計算最終傷害
var base_damage = 50
var final_damage = modifier_manager.apply_modifiers(
    "damage_bonus",
    base_damage,
    attacker,
    defender,
    action,
    current_turn,
    action.tags
)
```

## 文件結構
```
scripts/stat_modifier/
├── StatModifier.gd          # 單個屬性修正器
├── ModifierGroup.gd         # 修正器組（含條件和持續時間）
├── ModifierCondition.gd     # 觸發條件定義
├── StatModifierManager.gd   # 修正器管理器
└── README.md               # 本文檔
```

## 相關文檔
- 被動特質系統：`assets/docs/PassiveTrait.md`
- 神恩系統：`assets/docs/DivineFavor.md`
- 狀態效果系統：`assets/docs/StatusEffectSystem.md`
