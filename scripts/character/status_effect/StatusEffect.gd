# StatusEffect.gd
# 純資源類，只儲存靜態數據。不包含任何遊戲邏輯。
# 具體效果邏輯由 StatusEffectManager 和 StatusEffectHandlers 負責。

class_name StatusEffect extends Resource

# ==================== 基本信息 ====================

# 狀態的唯一標識符，例如："poison", "burning", "weakness"
@export var id: String = ""

# 狀態的名稱，用於 UI 顯示
@export var name: String = ""

# 狀態的文字描述
@export var description: String = ""

# ==================== 視覺資源 ====================

@export_group("Visual Assets")
# 狀態圖示路徑
@export var icon_path: String = ""

# 狀態特效場景路徑（持續顯示在角色身上）
@export var vfx_path: String = ""

# ==================== 持續時間 ====================

# 狀態的持續時間。通常以回合數計算，-1 代表永久。
@export var duration: int = 1

# 持續時間類型 (0=回合, 1=秒)
@export var duration_type: int = 0  # 0=TURN, 1=SECOND

# ==================== 分類 ====================

# 標記此狀態是正面（增益）或負面（減益）。
@export var is_debuff: bool = true

# 狀態類型，用於分類和查詢
# 範例："poison", "burn", "buff", "debuff"
@export var effect_type: String = ""

# ==================== 屬性修正 ====================

# 儲存對角色參數的影響，以字典形式表示。
# 範例：{ "atk": 10, "mdef": -3 }
# 這些修正值會在狀態應用時加到角色的基礎屬性上。
@export var stat_modifiers: Dictionary = {}

# ==================== 特殊參數 ====================

# 存儲效果特定的參數，由具體的效果處理器使用。
# 範例對於"poison"效果：{ "damage_per_turn": 5 }
# 範例對於"stun"效果：{ "miss_rate": 0.5 }
@export var effect_parameters: Dictionary = {}

# ==================== 觸發時機 ====================

# 此狀態是否在回合開始時觸發效果
@export var triggers_on_turn_start: bool = false

# 此狀態是否在回合結束時觸發效果
@export var triggers_on_turn_end: bool = false

# ==================== 備註 ====================
# 
# 示例 StatusEffect 資源 (Poison.tres)：
# ---
# id: "poison"
# name: "中毒"
# description: "每回合損失 5 HP"
# duration: 3
# is_debuff: true
# effect_type: "poison"
# effect_parameters: { "damage_per_turn": 5 }
# triggers_on_turn_end: true
# ---
#
# 示例 StatusEffect 資源 (Weakness.tres)：
# ---
# id: "weakness"
# name: "虛弱"
# description: "攻擊力降低 30%"
# duration: 2
# is_debuff: true
# effect_type: "stat_debuff"
# stat_modifiers: { "atk": -10 }  # 假設基礎 ATK 為 20，降低 50%
# ---
