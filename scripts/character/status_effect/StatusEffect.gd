# status_effects.gd
class_name StatusEffect extends Resource

# 狀態的唯一標識符，例如："Poisoned", "AdrenalineRush"
var id: String

# 狀態的持續時間。通常以回合數計算，-1 代表永久。
var duration: int

# 狀態的文字描述，用於 UI 顯示。
var description: String = ""

# 標記此狀態是正面（增益）或負面（減益）。
var is_debuff: bool = false

# 儲存對角色參數的影響，以字典形式表示。
# 範例：{ "ATK": 10, "MDEF": -3 }
var stat_modifiers: Dictionary = {}

# 回合開始時觸發的邏輯。
# 範例：["damage", 5] 代表造成 5 點傷害。
var on_turn_start_effect: PackedStringArray = []

# 回合結束時觸發的邏輯。
var on_turn_end_effect: PackedStringArray = []

func _init(p_id: String, p_duration: int = -1):
	self.id = p_id
	self.duration = p_duration

# 將此狀態的影響應用到目標角色。
# 在角色獲得此狀態時呼叫。
func apply_to(target_character):
	# TODO: 實現將 stat_modifiers 應用到角色屬性的邏輯。
	# 範例：target_character.add_stat_modifiers(stat_modifiers)
	pass

# 更新狀態的持續時間，並觸發回合效果。
# 應在每個遊戲回合結束時被呼叫。
func update():
	# 處理回合開始的效果
	if on_turn_start_effect.size() > 0:
		# TODO: 實現效果邏輯（例如：造成傷害、恢復生命等）。
		pass

	# 減少持續時間
	if duration > 0:
		duration -= 1
	
	# 處理回合結束的效果
	if on_turn_end_effect.size() > 0:
		# TODO: 實現效果邏輯（例如：造成中毒傷害）。
		pass

# 從目標角色身上移除此狀態。
# 應在狀態持續時間歸零或被驅散時呼叫。
func remove_from(target_character):
	# TODO: 實現移除屬性修正的邏輯。
	# 範例：target_character.remove_stat_modifiers(stat_modifiers)
	pass
