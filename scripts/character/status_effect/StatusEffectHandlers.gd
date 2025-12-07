# StatusEffectHandlers.gd
# 負責實現具體的狀態效果邏輯。
# 每個效果類型都有對應的處理函數。

extends Node
class_name StatusEffectHandlers

# 需要引用 BattleManager 來修改實際的 HP 值
static var battle_manager: BattleManager = null

# ==================== 主要入口 ====================

## 根據效果類型觸發相應的處理函數。
static func trigger_effect(character: Character, effect: StatusEffect) -> void:
	match effect.effect_type:
		"poison":
			_trigger_poison(character, effect)
		"burning":
			_trigger_burning(character, effect)
		"weakness":
			_trigger_weakness(character, effect)
		"stun":
			_trigger_stun(character, effect)
		"regen":
			_trigger_regen(character, effect)
		_:
			push_warning("未知的效果類型: %s" % effect.effect_type)

# ==================== 具體效果實現 ====================

## 中毒 - 每回合造成傷害
static func _trigger_poison(character: Character, effect: StatusEffect) -> void:
	if not battle_manager:
		return
	var damage = effect.effect_parameters.get("damage_per_turn", 1) as int
	var current_hp = battle_manager.get_current_hp(character)
	battle_manager.set_current_hp(character, current_hp - damage)
	print("%s 受到中毒傷害: %d HP" % [character.name, damage])

## 燃燒 - 每回合造成傷害
static func _trigger_burning(character: Character, effect: StatusEffect) -> void:
	if not battle_manager:
		return
	var damage = effect.effect_parameters.get("damage_per_turn", 2) as int
	var current_hp = battle_manager.get_current_hp(character)
	battle_manager.set_current_hp(character, current_hp - damage)
	print("%s 被燃燒傷害: %d HP" % [character.name, damage])

## 虛弱 - 純屬性修正，不需要特殊觸發邏輯
static func _trigger_weakness(character: Character, effect: StatusEffect) -> void:
	# 虛弱只通過 stat_modifiers 修正屬性，不需要回合觸發邏輯
	print("%s 處於虛弱狀態" % character.name)

## 眩暈 - 導致角色無法行動
static func _trigger_stun(character: Character, effect: StatusEffect) -> void:
	# 這裡可能需要與戰鬥系統整合
	# 例如：禁止角色在本回合選擇動作
	print("%s 被眩暈，無法行動" % character.name)

## 再生 - 每回合恢復生命值
static func _trigger_regen(character: Character, effect: StatusEffect) -> void:
	if not battle_manager:
		return
	var recovery = effect.effect_parameters.get("recovery_per_turn", 5) as int
	var current_hp = battle_manager.get_current_hp(character)
	battle_manager.set_current_hp(character, current_hp + recovery)
	print("%s 恢復生命值: %d HP" % [character.name, recovery])

# ==================== 輔助函數 ====================

## 檢查效果的特殊條件（可選）
static func check_condition(character: Character, effect: StatusEffect) -> bool:
	# 在這裡可以添加條件判定邏輯
	# 例如：某個效果可能對已經中毒的角色失效
	return true

## 應用效果的附加邏輯
static func apply_on_hit(attacker: Character, defender: Character, effect: StatusEffect) -> void:
	# 當效果在攻擊命中時觸發時使用
	# 例如：獲得狀態的概率判定
	pass
