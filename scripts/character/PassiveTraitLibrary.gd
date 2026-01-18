# PassiveTraitLibrary.gd
# 被動特質庫 - 硬編碼所有特質定義

class_name PassiveTraitLibrary
extends RefCounted

## 獲取所有可用的被動特質
static func get_all_traits() -> Array[PassiveTrait]:
	return [
		_create_brute_force(),
		_create_iron_body(),
		_create_last_stand(),
		_create_deadly_strike(),
		_create_critical_mastery(),
		_create_nimble_steps(),
		_create_regeneration(),
		_create_stamina_efficiency(),
		_create_mana_fountain(),
		_create_defense_mastery(),
		_create_evasion_training(),
		_create_perfect_balance(),
	]

## 按ID獲取特質
static func get_trait_by_id(trait_id: String) -> PassiveTrait:
	var all_traits = get_all_traits()
	for pasive_trait in all_traits:
		if pasive_trait.id == trait_id:
			return pasive_trait
	return null

# ============================================
# 具體特質定義
# ============================================

## 蠻力 - 物理傷害加成
static func _create_brute_force() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_brute_force", "蠻力", "物理招式傷害 +25%")
	var effects_array: Array[Effect] = [
		Effect.new("damage_bonus", "add", 0.25, ["physical"])
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["god_of_war"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 鋼鐵之軀 - 物理減傷
static func _create_iron_body() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_iron_body", "鋼鐵之軀", "受到物理傷害 -15%")
	var effects_array: Array[Effect] = [
		Effect.new("damage_reduction", "add", 0.15, ["physical"])
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["goddess_of_wisdom"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 背水一戰 - 低血量時傷害加成
static func _create_last_stand() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_last_stand", "背水一戰", "血量低於 30% 時傷害額外 +20%")
	var effects_array: Array[Effect] = [
		Effect.new("damage_bonus", "add", 0.20)
	]
	pasive_trait.effects = effects_array
	var condition = EffectCondition.new()
	condition.required_hp_range = Vector2(0, 0.3)
	var conditions_array: Array[EffectCondition] = [condition]
	pasive_trait.conditions = conditions_array
	return pasive_trait

## 致命一擊 - 增加爆擊率
static func _create_deadly_strike() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_deadly_strike", "致命一擊", "所有招式爆擊率 +10%")
	var effects_array: Array[Effect] = [
		Effect.new("critical_rate", "add", 0.10)
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["god_of_war"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 爆擊專精 - 提升爆擊傷害
static func _create_critical_mastery() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_critical_mastery", "爆擊專精", "爆擊傷害倍率 150% → 200%")
	var effects_array: Array[Effect] = [
		Effect.new("critical_damage_multiplier", "replace", 2.0)
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["god_of_war"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 靈巧身手 - 增加閃避率
static func _create_nimble_steps() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_nimble_steps", "靈巧身手", "閃避率 +20%")
	var effects_array: Array[Effect] = [
		Effect.new("dodge_chance", "add", 0.20)
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["goddess_of_wisdom"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 再生 - 每回合恢復HP
static func _create_regeneration() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_regeneration", "再生", "每回合恢復 8 HP")
	var effects_array: Array[Effect] = [
		Effect.new("hp_recovery_per_turn", "add", 8.0)
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["goddess_of_life"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 耐力效率 - 降低耐力消耗
static func _create_stamina_efficiency() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_stamina_efficiency", "耐力效率", "所有招式耐力消耗 -20%")
	var effects_array: Array[Effect] = [
		Effect.new("stamina_cost_reduction", "multiply", 0.20)
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["god_of_commerce"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 法力泉湧 - 每回合恢復MP
static func _create_mana_fountain() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_mana_fountain", "法力泉湧", "每回合恢復 10 MP")
	var effects_array: Array[Effect] = [
		Effect.new("mp_recovery_per_turn", "add", 10.0)
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["god_of_commerce"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 防守精通 - 防守時額外減傷
static func _create_defense_mastery() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_defense_mastery", "防守精通", "防守時額外減傷 25%")
	var effects_array: Array[Effect] = [
		Effect.new("damage_reduction", "add", 0.25)
	]
	pasive_trait.effects = effects_array
	var condition = EffectCondition.new()
	var required_stances: Array[String] = ["defend"]
	condition.required_stances = required_stances
	var conditions_array: Array[EffectCondition] = [condition]
	pasive_trait.conditions = conditions_array
	var synergy_ids: Array[String] = ["goddess_of_wisdom"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait

## 閃避訓練 - 增加閃避率(條件:敵方HP高於50%)
static func _create_evasion_training() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_evasion_training", "閃避訓練", "對手血量高時閃避率 +15%")
	var effects_array: Array[Effect] = [
		Effect.new("dodge_chance", "add", 0.15)
	]
	pasive_trait.effects = effects_array
	var condition = EffectCondition.new()
	condition.opponent_hp_range = Vector2(0.5, 1.0)
	var conditions_array: Array[EffectCondition] = [condition]
	pasive_trait.conditions = conditions_array
	return pasive_trait

## 完美平衡 - 全屬性小幅加成
static func _create_perfect_balance() -> PassiveTrait:
	var pasive_trait = PassiveTrait.new("passive_perfect_balance", "完美平衡", "所有傷害 +10%，所有傷害承受 -10%")
	var effects_array: Array[Effect] = [
		Effect.new("damage_bonus", "add", 0.10),
		Effect.new("damage_reduction", "add", 0.10)
	]
	pasive_trait.effects = effects_array
	var synergy_ids: Array[String] = ["god_of_balance"]
	pasive_trait.synergy_deity_ids = synergy_ids
	return pasive_trait
