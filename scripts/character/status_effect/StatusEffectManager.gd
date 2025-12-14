# StatusEffectManager.gd
# 負責管理角色的所有狀態效果。
# 處理應用、移除、更新、觸發等邏輯。

extends Node
class_name StatusEffectManager

# 持有此管理器的角色
var character: Character

# 當前應用於角色的狀態效果列表
# 結構：{ "effect_id": { "effect": StatusEffect, "remaining_duration": int } }
var active_effects: Dictionary = {}

# 狀態修正值緩存（用於性能優化）
# 結構：{ "atk": 0, "def": 0, ... }
var stat_modifiers_cache: Dictionary = {}

# ==================== 初始化 ====================

func _init(p_character: Character) -> void:
	character = p_character

# ==================== 應用 & 移除 ====================

## 向角色應用一個狀態效果。
## effect: StatusEffect 資源
func apply_effect(effect: StatusEffect) -> void:
	if not effect:
		push_error("StatusEffectManager: 嘗試應用 null 效果")
		return
	
	var effect_copy = effect.duplicate()
	active_effects[effect.id] = {
		"effect": effect_copy,
		"remaining_duration": effect_copy.duration
	}
	
	# 應用屬性修正
	if effect_copy.stat_modifiers.size() > 0:
		_apply_stat_modifiers(effect_copy.stat_modifiers)
	
	print("效果已應用: %s (持續 %d 回合)" % [effect.name, effect.duration])

## 移除指定 ID 的狀態效果。
func remove_effect(effect_id: String) -> void:
	if not active_effects.has(effect_id):
		return
	
	var effect_data = active_effects[effect_id]
	var effect = effect_data["effect"]
	
	# 移除屬性修正
	if effect.stat_modifiers.size() > 0:
		_remove_stat_modifiers(effect.stat_modifiers)
	
	active_effects.erase(effect_id)
	print("效果已移除: %s" % effect.name)

## 清除所有狀態效果。
func clear_all_effects() -> void:
	for effect_id in active_effects.keys():
		remove_effect(effect_id)

# ==================== 查詢 ====================

## 檢查角色是否擁有指定 ID 的效果。
func has_effect(effect_id: String) -> bool:
	return active_effects.has(effect_id)

## 獲取指定 ID 的效果數據。
func get_effect(effect_id: String) -> Dictionary:
	return active_effects.get(effect_id, {})

## 獲取所有活躍的效果。
func get_all_effects() -> Array:
	var effects = []
	for effect_data in active_effects.values():
		effects.append(effect_data["effect"])
	return effects

## 獲取所有減益效果。
func get_all_debuffs() -> Array:
	var debuffs = []
	for effect_data in active_effects.values():
		if effect_data["effect"].is_debuff:
			debuffs.append(effect_data["effect"])
	return debuffs

## 獲取所有增益效果。
func get_all_buffs() -> Array:
	var buffs = []
	for effect_data in active_effects.values():
		if not effect_data["effect"].is_debuff:
			buffs.append(effect_data["effect"])
	return buffs

# ==================== 回合更新 ====================

## 在回合開始時調用。
## 觸發所有 triggers_on_turn_start 的效果。
func on_turn_start() -> void:
	for effect_id in active_effects.keys():
		var effect_data = active_effects[effect_id]
		var effect = effect_data["effect"]
		
		if effect.triggers_on_turn_start:
			StatusEffectHandlers.trigger_effect(character, effect)

## 在回合結束時調用。
## 觸發所有 triggers_on_turn_end 的效果，並減少持續時間。
func on_turn_end() -> void:
	# 先觸發效果
	for effect_id in active_effects.keys():
		var effect_data = active_effects[effect_id]
		var effect = effect_data["effect"]
		
		if effect.triggers_on_turn_end:
			StatusEffectHandlers.trigger_effect(character, effect)
	
	# 再減少持續時間
	_update_durations()

## 更新所有效果的持續時間。
func _update_durations() -> void:
	var expired_effects = []
	
	for effect_id in active_effects.keys():
		var effect_data = active_effects[effect_id]
		
		# 跳過永久效果 (duration == -1)
		if effect_data["remaining_duration"] == -1:
			continue
		
		effect_data["remaining_duration"] -= 1
		
		# 效果已過期
		if effect_data["remaining_duration"] <= 0:
			expired_effects.append(effect_id)
	
	# 移除已過期的效果
	for effect_id in expired_effects:
		remove_effect(effect_id)

# ==================== 屬性修正 ====================

## 應用屬性修正。
func _apply_stat_modifiers(modifiers: Dictionary) -> void:
	for stat in modifiers.keys():
		if not stat_modifiers_cache.has(stat):
			stat_modifiers_cache[stat] = 0
		stat_modifiers_cache[stat] += modifiers[stat]
	
	_refresh_character_stats()

## 移除屬性修正。
func _remove_stat_modifiers(modifiers: Dictionary) -> void:
	for stat in modifiers.keys():
		if stat_modifiers_cache.has(stat):
			stat_modifiers_cache[stat] -= modifiers[stat]
	
	_refresh_character_stats()

## 刷新角色的計算屬性（考慮所有修正）。
func _refresh_character_stats() -> void:
	# 這裡調用 Character 的方法重新計算戰鬥屬性
	# 例如：character.apply_effect_modifiers(stat_modifiers_cache)
	# 具體實現取決於你的 Character 類設計
	pass

# ==================== 獲取修正值 ====================

## 獲取指定屬性的修正值。
func get_stat_modifier(stat: String) -> int:
	return stat_modifiers_cache.get(stat, 0)

## 獲取所有屬性修正值。
func get_all_stat_modifiers() -> Dictionary:
	return stat_modifiers_cache.duplicate()
