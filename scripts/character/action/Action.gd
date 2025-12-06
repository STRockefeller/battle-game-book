# Action.gd
extends Resource
class_name Action

# --- 基本信息 ---
@export var id: String
@export var name: String
@export var description: String

# --- 成本 ---
@export var stamina_cost: int = 0
@export var cost_mp: int = 0 
@export var cast_time: int = 0
@export var cooldown: int = 0

# --- 姿態限制 ---
@export var allowed_stances: PackedStringArray = []
@export var disallowed_stances: PackedStringArray = []

# --- 標籤與分類 ---
@export var tags: PackedStringArray = []
@export var is_movement: bool = false

# --- 傷害計算  ---
@export var damage_multiplier: float = 0.0
@export var power: int = 10 
@export var accuracy_modifier: float = 0.0
@export var critical_modifier: float = 0.0

# --- 距離與範圍 ---
@export var applicable_ranges: PackedStringArray = []
@export var out_of_range_penalty: Dictionary = {}

# --- 效果 ---
@export var effects_on_hit: PackedStringArray = []
@export var effects_on_use: PackedStringArray = []
@export var target_stance_change_to: String = ""
@export var user_stance_change_to: String = ""

@export var priority: int = 0  # 行動優先度

# 動作當前冷卻時間
var current_cooldown: int = 0

func is_usable_in(current_stance_id: String) -> bool:
	if allowed_stances.size() > 0:
		return allowed_stances.has(current_stance_id)
	return not disallowed_stances.has(current_stance_id)
