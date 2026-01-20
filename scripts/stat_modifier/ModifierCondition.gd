# ModifierCondition.gd
# 修正器觸發條件系統
# 支持多種條件組合(HP百分比、姿態、行動標籤、回合數等)

class_name ModifierCondition
extends RefCounted

## HP條件: 目標HP百分比必須在此範圍內 (0-1)
## 例如: Vector2(0, 0.3) = HP低於30%
var required_hp_range: Vector2 = Vector2(-1, -1)

## 姿態條件: 角色必須處於這些姿態之一
## 為空 = 無限制，例如: ["defend", "dodge"]
var required_stances: Array[String] = []

## 排除的姿態: 角色不能處於這些姿態
var excluded_stances: Array[String] = []

## 行動條件: 行動必須包含這些標籤
## 為空 = 無限制，例如: ["physical", "attack"]
var required_action_tags: Array[String] = []

## 行動條件: 排除的行動標籤
var excluded_action_tags: Array[String] = []

## 對手條件: 對手HP百分比必須在此範圍內
var opponent_hp_range: Vector2 = Vector2(-1, -1)

## 對手姿態條件: 對手必須處於這些姿態之一
var opponent_required_stances: Array[String] = []

## 回合條件: 僅在這些回合有效
## Vector2(-1, -1) = 無限制，例如: Vector2(1, 3) = 第1-3回合
var turn_range: Vector2 = Vector2(-1, -1)

## 是否無條件(總是觸發)
func is_always_active() -> bool:
	return required_hp_range == Vector2(-1, -1) and \
	       required_stances.is_empty() and \
	       excluded_stances.is_empty() and \
	       required_action_tags.is_empty() and \
	       opponent_hp_range == Vector2(-1, -1) and \
	       opponent_required_stances.is_empty() and \
	       turn_range == Vector2(-1, -1)

## 檢查條件是否滿足
func is_met(character: Character, opponent: Character, action: Action = null, turn: int = -1) -> bool:
	# 檢查自身HP條件
	if required_hp_range.x >= 0:
		var hp_ratio = float(character.current_hp) / character.max_hp
		if hp_ratio < required_hp_range.x or hp_ratio > required_hp_range.y:
			return false
	
	# 檢查自身姿態條件
	if not required_stances.is_empty():
		var current_stance_id = character.stance_manager.get_current_stance_id()
		if not (current_stance_id in required_stances):
			return false
	
	# 檢查排除的姿態
	if not excluded_stances.is_empty():
		var current_stance_id = character.stance_manager.get_current_stance_id()
		if current_stance_id in excluded_stances:
			return false
	
	# 檢查行動標籤條件
	if not required_action_tags.is_empty() and action:
		var has_required_tag = false
		for tag in required_action_tags:
			if tag in action.tags:
				has_required_tag = true
				break
		if not has_required_tag:
			return false
	
	# 檢查排除的行動標籤
	if not excluded_action_tags.is_empty() and action:
		for tag in excluded_action_tags:
			if tag in action.tags:
				return false
	
	# 檢查對手HP條件
	if opponent and opponent_hp_range.x >= 0:
		var opponent_hp_ratio = float(opponent.current_hp) / opponent.max_hp
		if opponent_hp_ratio < opponent_hp_range.x or opponent_hp_ratio > opponent_hp_range.y:
			return false
	
	# 檢查對手姿態條件
	if opponent and not opponent_required_stances.is_empty():
		var opponent_stance_id = opponent.stance_manager.get_current_stance_id()
		if not (opponent_stance_id in opponent_required_stances):
			return false
	
	# 檢查回合條件
	if turn_range.x >= 0:
		if turn < turn_range.x or turn > turn_range.y:
			return false
	
	return true

func _to_string() -> String:
	var conditions = []
	if required_hp_range.x >= 0:
		conditions.append("HP: %.0f%%-%.0f%%" % [required_hp_range.x * 100, required_hp_range.y * 100])
	if not required_stances.is_empty():
		conditions.append("Stances: [%s]" % ", ".join(required_stances))
	if not required_action_tags.is_empty():
		conditions.append("Tags: [%s]" % ", ".join(required_action_tags))
	if required_stances.is_empty() and required_action_tags.is_empty() and required_hp_range.x < 0:
		return "ModifierCondition(無條件)"
	return "ModifierCondition(%s)" % ", ".join(conditions)
