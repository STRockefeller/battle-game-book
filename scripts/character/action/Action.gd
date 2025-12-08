# Action.gd
extends Resource
class_name Action

# --- 基本信息 ---
@export var id: String
@export var name: String
@export var description: String

# --- 視覺和音效資源 ---
@export_group("Visual & Audio Assets")
@export var animation_sprite: String = ""  # 動作動畫精靈圖
@export var audio_cast: String = ""  # 施放音效
@export var audio_hit: String = ""  # 命中音效
@export var vfx_cast: String = ""  # 施放特效場景路徑
@export var vfx_hit: String = ""  # 命中特效場景路徑
@export var animation_duration: float = 0.5  # 動畫持續時間（秒）

# --- 成本 ---
@export var cost_stamina: int = 0
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

func can_use(user: Character, battle_manager: BattleManager = null) -> bool:
	if not battle_manager:
		return true  # 無法驗證，視為可用
	
	# 使用 cost_mp 或 cost_stamina
	var cost = cost_stamina if cost_stamina > 0 else cost_mp
	if battle_manager.get_sta(user) < cost:
		return false
	
	# 檢查冷卻時間
	var cooldowns = battle_manager.get_action_cooldowns(user)
	if cooldowns.has(id):
		return false
	
	return true

func is_usable_in(current_stance_id: String) -> bool:
	if allowed_stances.size() > 0:
		return allowed_stances.has(current_stance_id)
	return not disallowed_stances.has(current_stance_id)
