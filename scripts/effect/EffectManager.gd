# EffectManager.gd
# 效果管理系統 - 集中管理所有活躍的效果修正器

class_name EffectManager
extends RefCounted

## 所有活躍的效果修正器
var active_modifiers: Array[EffectModifier] = []

## 修正器緩存(按屬性分類)
var cached_modifiers: Dictionary = {}

## 緩存是否有效
var cache_valid: bool = false

## 添加一個效果修正器
func add_modifier(modifier: EffectModifier) -> void:
	if modifier:
		active_modifiers.append(modifier)
		invalidate_cache()

## 添加多個效果修正器
func add_modifiers(modifiers: Array[EffectModifier]) -> void:
	for modifier in modifiers:
		add_modifier(modifier)

## 移除一個效果修正器
func remove_modifier(modifier_id: String) -> void:
	active_modifiers = active_modifiers.filter(func(m: EffectModifier) -> bool:
		return m.id != modifier_id
	)
	invalidate_cache()

## 移除所有來自特定來源的修正器
func remove_modifiers_by_source(source: String) -> void:
	active_modifiers = active_modifiers.filter(func(m: EffectModifier) -> bool:
		return m.source != source
	)
	invalidate_cache()

## 清空所有修正器
func clear() -> void:
	active_modifiers.clear()
	invalidate_cache()

## 更新所有修正器的狀態(如持續時間)
func tick() -> void:
	for modifier in active_modifiers:
		modifier.tick()
	
	# 移除已過期的修正器
	active_modifiers = active_modifiers.filter(func(m: EffectModifier) -> bool:
		return m.active
	)
	invalidate_cache()

## 獲取指定屬性的所有活躍修正器
func get_active_modifiers(property: String, character: Character = null, 
                          opponent: Character = null, action: Action = null, 
                          turn: int = -1) -> Array[EffectModifier]:
	var result: Array[EffectModifier] = []
	
	for modifier in active_modifiers:
		# 檢查修正器是否應該被應用
		if not modifier.should_apply(character, opponent, action, turn):
			continue
		
		# 檢查修正器是否包含該屬性
		var has_property = false
		for effect in modifier.effects:
			if effect.property == property:
				has_property = true
				break
		
		if has_property:
			result.append(modifier)
	
	return result

## 應用效果到指定屬性(計算最終修正值)
func apply_effects(property: String, base_value: float, character: Character = null,
                  opponent: Character = null, action: Action = null, 
                  turn: int = -1, action_tags: Array[ActionTags.Tags] = []) -> float:
	var modifiers = get_active_modifiers(property, character, opponent, action, turn)
	var result = base_value
	var multiply_factor = 1.0
	var add_value = 0.0
	var replace_value: float = -9999999.0
	var should_replace = false
	
	for modifier in modifiers:
		for effect in modifier.effects:
			# 檢查標籤過濾
			if not effect.applies_to_tags(action_tags):
				continue
			
			match effect.operation:
				"add":
					add_value += effect.value
				"multiply":
					multiply_factor *= (1.0 + effect.value)
				"replace":
					replace_value = effect.value
					should_replace = true
	
	# 按順序應用修正
	if should_replace:
		result = replace_value
	else:
		result = result * multiply_factor + add_value
	
	return result

## 應用整數類效果(用於HP、MP等)
func apply_effects_int(property: String, base_value: int, character: Character = null,
                      opponent: Character = null, action: Action = null, 
                      turn: int = -1, action_tags: Array[ActionTags.Tags] = []) -> int:
	return int(apply_effects(property, float(base_value), character, opponent, 
	                         action, turn, action_tags))

## 檢查是否有特定來源的活躍修正器
func has_modifier_from_source(source: String) -> bool:
	for modifier in active_modifiers:
		if modifier.source == source:
			return true
	return false

## 使緩存失效
func invalidate_cache() -> void:
	cache_valid = false

## 獲取所有活躍修正器的調試信息
func get_debug_info() -> String:
	var info = "EffectManager - Active Modifiers: %d\n" % active_modifiers.size()
	for modifier in active_modifiers:
		info += "  - %s (source: %s, effects: %d)\n" % [modifier.id, modifier.source, modifier.effects.size()]
	return info

## 打印所有活躍修正器
func print_active_modifiers() -> void:
	print(get_debug_info())
