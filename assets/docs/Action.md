# Action

## 核心概念

動作（Action）系統經過簡化，招式擁有**固定傷害值**、**固定命中率**和**固定暴擊率**，不受角色攻防屬性影響。這讓每個招式都有明確的戰術定位，玩家更容易做出決策。

---

## 核心參數

每個動作包含以下核心參數：

* **id**：動作的唯一標識符（例如：`quick_slash`, `fireball`）
* **name**：動作的顯示名稱（例如：「快速斬擊」、「火球術」）
* **description**：動作的詳細說明
* **damage**：**固定傷害值**（不受角色屬性影響）
* **accuracy**：**基礎命中率**（%）
* **critical_rate**：**基礎爆擊率**（%）
* **cost_stamina**：耐力消耗
* **cost_mp**：MP 消耗（魔法招式）
* **cooldown**：冷卻時間（回合數）
* **tags**：標籤陣列，用於分類和互動（例如：`[Physical, Slash]`, `[Magic, Fire]`）

---

## 距離系統（可選參數）

某些招式可設定**距離相關命中率**：

* **accuracy_by_range**：根據距離調整命中率
  - `near`：近距離命中率
  - `mid`：中距離命中率
  - `far`：遠距離命中率

**範例**：
- 近戰招式：近 95%、中 80%、遠 50%
- 遠程招式：近 80%、中 95%、遠 85%
- 魔法招式：近 80%、中 90%、遠 90%

---

## 效果與交互

* **effects**：動作可施加的**狀態效果**列表
  - 觸發時機：命中後生效或使用時立即生效
  - 範例：`[Poison]`, `[Stun]`, `[ATK_Down]`

* **stance_change**：改變姿態
  - 自身姿態變化（例如：進入防禦姿態）
  - 敵人姿態變化（例如：造成倒地、擊飛）

  **distance_change**: 改變雙方距離
  - 只有兩種固定Action: 接近和遠離
  - 距離分三種 近中遠 定義在戰鬥環境
  - 雙方同時進行移動會適用雙方的移動行為。例如 "遠" 的情況下 雙方同時接近 會跳過 "中" 變為 "近"

---

## 招式範例

### 基礎物理攻擊

**快速斬擊(Quick Slash)**
```yaml
id: quick_slash
name: 快速斬擊
damage: 25
accuracy_by_range:
  near: 95%
  mid: 85%
  far: 60%
critical_rate: 5%
cost_stamina: 10
tags: [Physical, Slash]
description: 快速的基礎攻擊,近距離命中率高
```

**重擊(Power Strike)**
```yaml
id: power_strike
name: 重擊
damage: 60
accuracy_by_range:
  near: 80%
  mid: 60%
  far: 30%
critical_rate: 10%
cost_stamina: 30
cooldown: 2
tags: [Physical, Heavy]
description: 蓄力的強力一擊,高傷害但必須近距離才有效
```

**精準刺擊(Precise Strike)**
```yaml
id: precise_strike
name: 精準刺擊
damage: 35
accuracy_by_range:
  near: 98%
  mid: 88%
  far: 65%
critical_rate: 15%
cost_stamina: 20
tags: [Physical, Precision]
description: 專注於要害的攻擊,近距離時極高命中率和爆擊率
```

---

### 魔法攻擊

**火球術（Fireball）**
```yaml
id: fireball
name: 火球術
damage: 50
accuracy_by_range:
  near: 80%
  mid: 90%
  far: 85%
critical_rate: 8%
cost_mp: 25
cooldown: 1
tags: [Magic, Fire]
description: 發射火球攻擊遠處敵人，中距離命中率最高
```

**冰箭(Ice Arrow)**
```yaml
id: ice_arrow
name: 冰箭
damage: 30
accuracy_by_range:
  near: 75%
  mid: 90%
  far: 95%
critical_rate: 5%
cost_mp: 15
effects: [Slow]
tags: [Magic, Ice]
description: 射出冰箭,遠距離命中率更高,命中後降低敵人速度
```

**治療術(Heal)**
```yaml
id: heal
name: 治療術
damage: -40  # 負值表示恢復
accuracy_by_range:
  near: 100%
  mid: 100%
  far: 100%
critical_rate: 0%
cost_mp: 30
tags: [Magic, Heal]
description: 恢復 40 HP,不受距離影響
```

---

### 基礎(共通)招式

不允許擴充，寫死在程式碼中。行動配置階段會強制要求配置一定數量的基礎行動。

**防禦(Guard)**
```yaml
id: guard
name: 防禦
damage: 0
accuracy_by_range:
  near: 100%
  mid: 100%
  far: 100%
cost_stamina: 5
stance_change: Guarding  # 進入防禦姿態
tags: [Defense]
description: 進入防禦姿態,大幅減少受到的傷害,不受距離影響
```

**休息(Rest)**
```yaml
id: rest
name: 休息
damage: 0
accuracy_by_range:
  near: 100%
  mid: 100%
  far: 100%
cost_stamina: -30  # 負值表示恢復
tags: [Recovery]
description: 休息一回合,恢復 30 耐力,不受距離影響
```

**上挑斬(Uppercut)**
```yaml
id: uppercut
name: 上挑斬
damage: 40
accuracy_by_range:
  near: 90%
  mid: 70%
  far: 35%
critical_rate: 5%
cost_stamina: 25
stance_change_target: Airborne  # 使敵人進入滯空姿態
tags: [Physical, Slash, Launch]
description: 向上揮擊,將敵人擊飛至空中,必須近距離才容易命中
```

---

## 遊戲機制

### 冷卻時間（Cooldown）
- 動作使用後進入冷卻，冷卻期間無法再次使用
- 冷卻時間以回合為單位
- 冷卻為 0 表示無冷卻限制（每回合都可用）

### 標籤交互（Tag Interactions）
- 標籤用於觸發特殊互動
- 範例：
  - `Water` 招式對 `Burning` 目標額外傷害 +50%
  - `Heavy` 招式更容易擊倒對手
  - `Precision` 招式無視部分閃避率

### 距離影響
- 某些招式根據距離調整命中率
- 近戰招式在近距離更有效
- 遠程招式在中遠距離更有效
- 魔法招式通常不受距離影響太多

