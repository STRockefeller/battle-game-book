# EffectModifier.gd
# 效果修正器 - 管理一個效果的應用
# 包含效果本身、觸發條件、來源等信息

class_name EffectModifier
extends RefCounted

## 修正器唯一標識
var id: String = ""

## 效果來源: "passive" / "divine" / "stance" / "status"
var source: String = "passive"

## 該修正器包含的所有效果
var effects: Array[Effect] = []

## 觸發條件(可為null表示無條件)
var condition: EffectCondition = null

## 是否當前激活
var active: bool = true

## 持續時間(回合數) -1表示永久
var duration: int = -1

## 應用次數限制 -1表示無限
var remaining_uses: int = -1

func _init(p_id: String = "", p_source: String = "passive", 
           p_effects: Array[Effect] = [], p_condition: EffectCondition = null) -> void:
	id = p_id
	source = p_source
	effects = p_effects
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

## 獲取特定屬性的所有效果
func get_effects_for_property(property: String) -> Array[Effect]:
	return effects.filter(func(e: Effect) -> bool: return e.property == property)

## 檢查是否適用於特定的行動標籤
func applies_to_tags(action_tags: Array[String]) -> bool:
	# 如果沒有效果，不適用
	if effects.is_empty():
		return false
	
	# 只要有一個效果適用，就返回true
	for effect in effects:
		if effect.applies_to_tags(action_tags):
			return true
	
	return false

func _to_string() -> String:
	var duration_str = "永久" if duration == -1 else "%d回合" % duration
	var effect_count = effects.size()
	return "EffectModifier(%s, 源: %s, 效果數: %d, %s)" % [id, source, effect_count, duration_str]
