# StatModifierManager.gd
# 屬性修正器管理系統 - 集中管理所有活躍的修正器組

class_name StatModifierManager
extends RefCounted

## 所有活躍的修正器組
var active_groups: Array[ModifierGroup] = []

## 修正器緩存(按屬性分類)
var cached_groups: Dictionary = {}

## 緩存是否有效
var cache_valid: bool = false

## 添加一個修正器組
func add_group(group: ModifierGroup) -> void:
	if group:
		active_groups.append(group)
		invalidate_cache()

## 添加多個修正器組
func add_groups(groups: Array[ModifierGroup]) -> void:
	for group in groups:
		add_group(group)

## 移除一個修正器組
func remove_group(group_id: String) -> void:
	active_groups = active_groups.filter(func(g: ModifierGroup) -> bool:
		return g.id != group_id
	)
	invalidate_cache()

## 移除所有來自特定來源的修正器組
func remove_groups_by_source(source: String) -> void:
	active_groups = active_groups.filter(func(g: ModifierGroup) -> bool:
		return g.source != source
	)
	invalidate_cache()

## 清空所有修正器組
func clear() -> void:
	active_groups.clear()
	invalidate_cache()

## 更新所有修正器組的狀態(如持續時間)
func tick() -> void:
	for group in active_groups:
		group.tick()
	
	# 移除已過期的修正器組
	active_groups = active_groups.filter(func(g: ModifierGroup) -> bool:
		return g.active
	)
	invalidate_cache()

## 獲取指定屬性的所有活躍修正器組
func get_active_groups(property: String, character: Character = null, 
                       opponent: Character = null, action: Action = null, 
                       turn: int = -1) -> Array[ModifierGroup]:
	var result: Array[ModifierGroup] = []
	
	for group in active_groups:
		# 檢查修正器組是否應該被應用
		if not group.should_apply(character, opponent, action, turn):
			continue
		
		# 檢查修正器組是否包含該屬性
		var has_property = false
		for modifier in group.modifiers:
			if modifier.property == property:
				has_property = true
				break
		
		if has_property:
			result.append(group)
	
	return result

## 應用修正器到指定屬性(計算最終修正值)
func apply_modifiers(property: String, base_value: float, character: Character = null,
                     opponent: Character = null, action: Action = null, 
                     turn: int = -1, action_tags: Array[ActionTags.Tags] = []) -> float:
	var groups = get_active_groups(property, character, opponent, action, turn)
	var result = base_value
	var multiply_factor = 1.0
	var add_value = 0.0
	var replace_value: float = -9999999.0
	var should_replace = false
	
	for group in groups:
		for modifier in group.modifiers:
			# 檢查屬性是否匹配
			if modifier.property != property:
				continue
			
			# 檢查標籤過濾
			if not modifier.applies_to_tags(action_tags):
				continue
			
			match modifier.operation:
				"add":
					add_value += modifier.value
				"multiply":
					multiply_factor *= (1.0 + modifier.value)
				"replace":
					replace_value = modifier.value
					should_replace = true
	
	# 按順序應用修正
	if should_replace:
		result = replace_value
	else:
		result = result * multiply_factor + add_value
	
	return result

## 應用整數類修正器(用於HP、MP等)
func apply_modifiers_int(property: String, base_value: int, character: Character = null,
                         opponent: Character = null, action: Action = null, 
                         turn: int = -1, action_tags: Array[ActionTags.Tags] = []) -> int:
	return int(apply_modifiers(property, float(base_value), character, opponent, 
	                            action, turn, action_tags))

## 檢查是否有特定來源的活躍修正器組
func has_group_from_source(source: String) -> bool:
	for group in active_groups:
		if group.source == source:
			return true
	return false

## 使緩存失效
func invalidate_cache() -> void:
	cache_valid = false

## 獲取所有活躍修正器組的調試信息
func get_debug_info() -> String:
	var info = "StatModifierManager - Active Groups: %d\n" % active_groups.size()
	for group in active_groups:
		info += "  - %s (source: %s, modifiers: %d)\n" % [group.id, group.source, group.modifiers.size()]
	return info

## 打印所有活躍修正器組
func print_active_groups() -> void:
	print(get_debug_info())
