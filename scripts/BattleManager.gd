# BattleManager.gd
extends Node
class_name BattleManager

var characters: Array[Character] = []
var current_distance: String = "mid"

# 執行一個動作
func execute_action(user: Character, target: Character, action: Action) -> bool:
	# 1. 檢查冷卻 & 姿態 & stamina
	if user.action_cooldowns.has(action.id):
		return false
	if not action.is_usable_in(user.current_stance.id):
		return false
	if user.STA < action.stamina_cost:
		return false
	
	# 2. 扣 stamina
	user.STA -= action.stamina_cost
	
	# 3. 應用 effects_on_use
	for effect_id in action.effects_on_use:
		var effect = load_effect(effect_id)
		if effect:
			user.apply_status_effect(effect)
	
	# 4. 計算命中 & 傷害
	var accuracy = user.ACC + action.accuracy_modifier
	var damage = user.ATK * action.damage_multiplier
	if not action.applicable_ranges.has(current_distance):
		if action.out_of_range_penalty.has("accuracy_modifier"):
			accuracy += action.out_of_range_penalty["accuracy_modifier"]
		if action.out_of_range_penalty.has("damage_multiplier"):
			damage *= action.out_of_range_penalty["damage_multiplier"]

	var hit = _roll_hit(accuracy, target.EVA)
	if hit:
		target.HP -= max(0, damage - target.DEF)
		
		# 5. 命中後的效果
		for effect_id in action.effects_on_hit:
			var effect = load_effect(effect_id)
			if effect:
				target.apply_status_effect(effect)
		if action.target_stance_change_to != "":
			target.current_stance = load_stance(action.target_stance_change_to)
	
	# 6. 使用者姿態改變
	if action.user_stance_change_to != "":
		user.current_stance = load_stance(action.user_stance_change_to)
	
	# 7. 設置冷卻
	if action.cooldown > 0:
		user.action_cooldowns[action.id] = action.cooldown
	
	return true

func _roll_hit(acc: float, eva: float) -> bool:
	var chance = acc - eva
	return randf() * 100 < clamp(chance, 5, 95)

func load_effect(effect_id: String) -> StatusEffect:
	# TODO: 從資源庫載入
	return null

func load_stance(stance_id: String) -> Stance:
	# TODO: 從資源庫載入
	return null
