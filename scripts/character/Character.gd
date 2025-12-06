# Character.gd
class_name Character extends Resource

# --- 基礎屬性 ---
var STR: int = 0
var INT: int = 0
var AGI: int = 0
var CON: int = 0
var LUK: int = 0

# --- 戰鬥屬性 (動態計算) ---
var HP: int = 0
var MP: int = 0
var STA: int = 0
var ATK: int = 0
var MATK: int = 0
var DEF: int = 0
var MDEF: int = 0
var ACC: int = 0
var EVA: int = 0
var CRT: float = 0.0

# --- 角色狀態管理 ---
# 當前姿態，為 Stance 類別的實例
var current_stance: Stance
# 當前生效中的狀態效果
var active_effects: Array[StatusEffect] = []
# 動作冷卻時間，使用字典來儲存，例如：{"slash": 3}
var action_cooldowns: Dictionary = {}

# --- 動作列表 ---
# 角色可執行的所有動作，Action 類別的實例陣列
var available_actions: Array[Action] = []

# --- 角色核心方法 ---

# 根據基礎屬性計算所有戰鬥屬性
func calculate_stats():
	HP = CON * 20
	MP = INT * 15
	STA = CON * 8
	
	ATK = STR * 2
	MATK = INT * 2
	
	DEF = CON * 2
	MDEF = INT * 2
	
	ACC = AGI * 2
	EVA = AGI * 2 + LUK
	CRT = LUK * 1.0 + AGI * 0.5

# 應用一個狀態效果到角色身上
func apply_status_effect(effect: StatusEffect):
	active_effects.append(effect)
	effect.apply_to(self)
	
# 移除一個狀態效果
func remove_status_effect(effect: StatusEffect):
	if active_effects.has(effect):
		effect.remove_from(self)
		active_effects.erase(effect)

# 更新所有狀態效果（在每回合結束時呼叫）
func update_status_effects():
	var effects_to_remove: Array[StatusEffect] = []
	for effect in active_effects:
		effect.update()
		if effect.duration == 0:
			effects_to_remove.append(effect)
	
	for effect in effects_to_remove:
		remove_status_effect(effect)

# 更新所有動作的冷卻時間
func update_cooldowns():
	var actions_to_remove: PackedStringArray = []
	for action_id in action_cooldowns:
		action_cooldowns[action_id] -= 1
		if action_cooldowns[action_id] <= 0:
			actions_to_remove.append(action_id)
			
	for action_id in actions_to_remove:
		action_cooldowns.erase(action_id)

# 根據當前姿態，獲取可用的動作列表
func get_available_actions() -> Array[Action]:
	var usable_actions: Array[Action] = []
	for action in available_actions:
		# 檢查冷卻時間
		if action_cooldowns.has(action.id):
			continue
		
		# 檢查姿態限制
		if action.is_usable_in(current_stance.id):
			usable_actions.append(action)
	
	return usable_actions
