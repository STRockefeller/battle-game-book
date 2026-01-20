# DamageEffect.gd
# 傷害效果積木
# 實現即時傷害計算，支援屬性加成、傷害類型、爆擊等

extends EffectComponent
class_name DamageEffect

# ==================== 傷害類型 ====================

enum DamageType {
	PHYSICAL,    # 物理傷害
	MAGICAL,     # 魔法傷害
	TRUE         # 真實傷害（無視防禦）
}

# ==================== 屬性 ====================

## 基礎傷害值
@export var base_damage: int = 10

## 傷害類型
@export var damage_type: DamageType = DamageType.PHYSICAL

## 縮放屬性（用於計算傷害加成）
## 可選值: "atk", "int", "agi", "str" 等
@export var scaling_stat: String = "atk"

## 縮放倍率（最終傷害 = base_damage + scaling_stat * scaling_multiplier）
@export var scaling_multiplier: float = 0.0

## 傷害倍率（乘法加成，例如 1.5 表示 150% 傷害）
@export var damage_multiplier: float = 1.0

## 是否可以爆擊
@export var can_crit: bool = true

## 是否受防禦影響
@export var ignore_defense: bool = false

## 額外傷害加成百分比（用於條件加成，例如對倒地目標 +50%）
@export var bonus_damage_percent: float = 0.0

# ==================== 實現 ====================

func execute(user: Character, target: Character, context: Dictionary) -> Dictionary:
	var result = {
		"type": "damage",
		"damage": 0,
		"actual_damage": 0,
		"is_critical": false,
		"damage_type": get_damage_type_name()
	}
	
	# 計算基礎傷害
	var calculated_damage = _calculate_damage(user, target, context)
	result["damage"] = calculated_damage
	
	# 檢查是否爆擊
	var is_crit = false
	if can_crit:
		is_crit = _check_critical(user, context)
		result["is_critical"] = is_crit
	
	# 應用爆擊倍率
	if is_crit:
		var crit_multiplier = context.get("crit_multiplier", 1.5)
		calculated_damage = int(calculated_damage * crit_multiplier)
	
	# 應用防禦減免（除非是真實傷害或忽略防禦）
	if not ignore_defense and damage_type != DamageType.TRUE:
		calculated_damage = _apply_defense(calculated_damage, user, target, context)
	
	result["actual_damage"] = calculated_damage
	
	# 應用傷害到目標
	var battle_manager = context.get("battle_manager")
	if battle_manager:
		var current_hp = battle_manager.get_current_hp(target)
		battle_manager.set_current_hp(target, current_hp - calculated_damage)
		
		print("[DamageEffect] %s 對 %s 造成 %d 傷害 %s" % [
			user.get_display_name(),
			target.get_display_name(),
			calculated_damage,
			"(爆擊!)" if is_crit else ""
		])
	
	return result

## 計算基礎傷害
func _calculate_damage(user: Character, target: Character, context: Dictionary) -> int:
	var damage = base_damage
	
	# 添加屬性縮放
	if scaling_stat and scaling_multiplier > 0.0:
		var stat_value = user.get_effective_stat(scaling_stat)
		damage += int(stat_value * scaling_multiplier)
	
	# 應用傷害倍率
	damage = int(damage * damage_multiplier)
	
	# 應用額外加成百分比
	if bonus_damage_percent > 0.0:
		damage = int(damage * (1.0 + bonus_damage_percent))
	
	# 應用被動特質加成（如果有 modifier_manager）
	var battle_manager = context.get("battle_manager")
	if battle_manager and battle_manager.modifier_manager:
		var action = context.get("action")
		var tags = action.tags if action else []
		var turn = context.get("turn", 0)
		
		var damage_bonus = battle_manager.modifier_manager.apply_modifiers(
			"damage_bonus", 0.0, user, target, action, turn, tags
		)
		
		if damage_bonus > 0.0:
			damage = int(damage * (1.0 + damage_bonus))
	
	return max(1, damage)  # 最少造成 1 點傷害

## 檢查是否爆擊
func _check_critical(user: Character, context: Dictionary) -> bool:
	var action = context.get("action")
	var base_crit_rate = action.critical_rate if action else 0.0
	
	# 獲取爆擊率加成（來自被動特質）
	var battle_manager = context.get("battle_manager")
	if battle_manager and battle_manager.modifier_manager:
		var target = context.get("target")
		var turn = context.get("turn", 0)
		var tags = action.tags if action else []
		
		var crit_bonus = battle_manager.modifier_manager.apply_modifiers(
			"critical_rate", 0.0, user, target, action, turn, tags
		)
		
		base_crit_rate += crit_bonus * 100.0
	
	return randf() * 100.0 < base_crit_rate

## 應用防禦減免
func _apply_defense(damage: int, user: Character, target: Character, context: Dictionary) -> int:
	var battle_manager = context.get("battle_manager")
	if not battle_manager or not battle_manager.modifier_manager:
		return damage
	
	var action = context.get("action")
	var turn = context.get("turn", 0)
	var tags = action.tags if action else []
	
	# 獲取防禦減傷加成
	var defense_reduction = battle_manager.modifier_manager.apply_modifiers(
		"damage_reduction", 0.0, target, user, action, turn, tags
	)
	
	if defense_reduction > 0.0:
		damage = int(damage * (1.0 - defense_reduction))
	
	return max(1, damage)  # 最少造成 1 點傷害

## 獲取傷害類型名稱
func get_damage_type_name() -> String:
	match damage_type:
		DamageType.PHYSICAL:
			return "物理"
		DamageType.MAGICAL:
			return "魔法"
		DamageType.TRUE:
			return "真實"
		_:
			return "未知"

## 重寫顯示文本
func get_display_text() -> String:
	if description:
		return description
	
	var text = "造成 %d" % base_damage
	
	if scaling_multiplier > 0.0:
		text += " + %s×%.1f" % [scaling_stat.to_upper(), scaling_multiplier]
	
	if damage_multiplier != 1.0:
		text += " (×%.1f)" % damage_multiplier
	
	text += " %s傷害" % get_damage_type_name()
	
	if bonus_damage_percent > 0.0:
		text += " +%d%% 加成" % (bonus_damage_percent * 100)
	
	return text

func _to_string() -> String:
	return "DamageEffect(%s, %d 基礎傷害, %s)" % [
		effect_id if effect_id else "unnamed",
		base_damage,
		get_condition_text()
	]
