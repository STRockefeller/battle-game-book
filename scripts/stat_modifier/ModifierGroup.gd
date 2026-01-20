# ModifierGroup.gd
# 修正器組 - 管理一組屬性修正器的應用
# 包含多個修正器、觸發條件、來源等信息

class_name ModifierGroup
extends RefCounted

## 修正器唯一標識
var id: String = ""

## 效果來源: "passive" / "divine" / "stance" / "status"
var source: String = "passive"

## 該修正器組包含的所有屬性修正器
var modifiers: Array[StatModifier] = []

## 觸發條件(可為null表示無條件)
var condition: ModifierCondition = null

## 是否當前激活
var active: bool = true

## 持續時間(回合數) -1表示永久
var duration: int = -1

## 應用次數限制 -1表示無限
var remaining_uses: int = -1

func _init(p_id: String = "", p_source: String = "passive", 
           p_modifiers: Array[StatModifier] = [], p_condition: ModifierCondition = null) -> void:
	id = p_id
	source = p_source
	modifiers = p_modifiers
	condition = p_condition

## 檢查修正器是否應該被應用
func should_apply(character: Character, opponent: Character = null, 
                 action: Action = null, turn: int = -1) -> bool:
	if not active:
		return false
	
	if remaining_uses == 0:
		return false
	
	# 如果有條件，檢查條件是否滿足
	if condition and not condition.is_met(character, opponent, action, turn):
		return false
	
	return true

## 應用一次效果(消耗使用次數)
func use_once() -> void:
	if remaining_uses > 0:
		remaining_uses -= 1

## 更新持續時間
func tick() -> void:
	if duration > 0:
		duration -= 1
		if duration == 0:
			active = false

## 獲取特定屬性的所有修正器
func get_modifiers_for_property(property: String) -> Array[StatModifier]:
	return modifiers.filter(func(m: StatModifier) -> bool: return m.property == property)

## 檢查是否適用於特定的行動標籤
func applies_to_tags(action_tags: Array[String]) -> bool:
	# 如果沒有修正器，不適用
	if modifiers.is_empty():
		return false
	
	# 只要有一個修正器適用，就返回true
	for modifier in modifiers:
		if modifier.applies_to_tags(action_tags):
			return true
	
	return false

func _to_string() -> String:
	var duration_str = "永久" if duration == -1 else "%d回合" % duration
	var modifier_count = modifiers.size()
	return "ModifierGroup(%s, 源: %s, 修正器數: %d, %s)" % [id, source, modifier_count, duration_str]
