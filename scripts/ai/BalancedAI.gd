# BalancedAI.gd
# 平衡型 AI - 根據戰況動態調整策略，攻防兼備
extends AIBehavior
class_name BalancedAI

# 狀態閾值
const AGGRESSIVE_HP_THRESHOLD = 0.6 # 高於此值時偏攻擊
const DEFENSIVE_HP_THRESHOLD = 0.3 # 低於此值時偏防守
const LOW_STAMINA_THRESHOLD = 0.25

func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	if available_actions.size() == 0:
		return null
	
	# 過濾出可以使用的動作
	var affordable_actions = get_affordable_actions(available_actions, character, battle_manager)
	
	if affordable_actions.size() == 0:
		return _find_lowest_cost_action(available_actions)
	
	var hp_ratio = get_hp_ratio(character, battle_manager)
	var stamina_ratio = get_stamina_ratio(character, battle_manager)
	var opponent_hp_ratio = get_opponent_hp_ratio(opponent, battle_manager)
	
	# 動態決定當前策略
	var strategy = _determine_strategy(hp_ratio, stamina_ratio, opponent_hp_ratio)
	
	# 緊急處理
	if strategy == "emergency":
		# 極度危險時優先防禦或治療
		var guard_action = _find_action_with_tag(affordable_actions, "guard")
		if guard_action:
			return guard_action
		var heal_action = _find_action_with_tag(affordable_actions, "healing")
		if heal_action:
			return heal_action
	
	# 低耐力時休息
	if stamina_ratio < LOW_STAMINA_THRESHOLD:
		var rest_action = _find_action_with_tag(affordable_actions, "rest")
		if rest_action:
			return rest_action
	
	# 評估所有動作
	var best_action: Action = null
	var best_score: float = -999999.0
	
	for action in affordable_actions:
		var score = evaluate_action(action, character, opponent, battle_manager)
		if score > best_score:
			best_score = score
			best_action = action
	
	return best_action

## 根據當前狀況決定策略
func _determine_strategy(hp_ratio: float, stamina_ratio: float, opponent_hp_ratio: float) -> String:
	# 緊急狀態：血量極低
	if hp_ratio < 0.15:
		return "emergency"
	
	# 防守模式：我方血量低
	if hp_ratio < DEFENSIVE_HP_THRESHOLD:
		return "defensive"
	
	# 追擊模式：對手血量低
	if opponent_hp_ratio < 0.25:
		return "aggressive"
	
	# 攻擊模式：我方血量健康
	if hp_ratio > AGGRESSIVE_HP_THRESHOLD:
		return "aggressive"
	
	# 平衡模式：其他情況
	return "balanced"

func evaluate_action(action: Action, character: Character, opponent: Character, battle_manager) -> float:
	var score: float = 0.0
	
	var hp_ratio = get_hp_ratio(character, battle_manager)
	var stamina_ratio = get_stamina_ratio(character, battle_manager)
	var opponent_hp_ratio = get_opponent_hp_ratio(opponent, battle_manager)
	var strategy = _determine_strategy(hp_ratio, stamina_ratio, opponent_hp_ratio)
	
	# 基礎評分
	score += _evaluate_base_damage(action)
	score += _evaluate_hit_rate(action)
	score += _evaluate_cost_efficiency(action)
	score += _evaluate_status_effects(action)
	
	# 根據策略調整權重
	match strategy:
		"aggressive":
			score = _apply_aggressive_modifiers(score, action, character, opponent, battle_manager)
		"defensive":
			score = _apply_defensive_modifiers(score, action, character, opponent, battle_manager)
		"balanced":
			score = _apply_balanced_modifiers(score, action, character, opponent, battle_manager)
		"emergency":
			score = _apply_emergency_modifiers(score, action, character, opponent, battle_manager)
	
	# 添加隨機性
	score *= randf_range(0.92, 1.08)
	
	return score

## 評估基礎傷害
func _evaluate_base_damage(action: Action) -> float:
	return action.damage * 10.0

## 評估命中率
func _evaluate_hit_rate(action: Action) -> float:
	return action.accuracy * 0.5

## 評估性價比
func _evaluate_cost_efficiency(action: Action) -> float:
	var total_cost = action.cost_stamina + action.cost_mp
	if total_cost == 0:
		return 20.0
	return (float(action.damage) / float(total_cost)) * 5.0

## 評估狀態效果
func _evaluate_status_effects(action: Action) -> float:
	var score = 0.0
	for effect_id in action.effects_on_hit:
		match effect_id:
			"burning", "poison":
				score += 12.0
			"weakness":
				score += 10.0
			"regen":
				score += 15.0
			"knockdown":
				score += 18.0
	return score

## 應用攻擊型修正
func _apply_aggressive_modifiers(base_score: float, action: Action, _character: Character, _opponent: Character, _battle_manager: BattleManager) -> float:
	var score = base_score
	
	# 高傷害加成
	if action.base_damage > 10:
		score *= 1.4
	
	# 攻擊性標籤加成
	if "physical" in action.tags or "magic" in action.tags:
		score += 25.0
	
	# 懲罰防禦動作
	if "guard" in action.tags:
		score *= 0.4
	if "rest" in action.tags:
		score *= 0.5
	
	return score

## 應用防守型修正
func _apply_defensive_modifiers(base_score: float, action: Action, _character: Character, _opponent: Character, _battle_manager: BattleManager) -> float:
	var score = base_score
	
	# 防禦動作大幅加成
	if "guard" in action.tags:
		score += 50.0
	if "healing" in action.tags:
		score += 45.0
	if "rest" in action.tags:
		score += 30.0
	
	# 低消耗加成
	if action.cost_stamina + action.cost_mp < 15:
		score *= 1.3
	
	# 高命中率加成
	if action.accuracy >= 85.0:
		score *= 1.2
	
	return score

## 應用平衡型修正
func _apply_balanced_modifiers(base_score: float, action: Action, _character: Character, _opponent: Character, _battle_manager: BattleManager) -> float:
	var score = base_score
	
	# 中等傷害動作加成
	if action.damage >= 8 and action.damage <= 15:
		score *= 1.2
	
	# 性價比高的動作加成
	var total_cost = action.cost_stamina + action.cost_mp
	if total_cost > 0:
		var efficiency = float(action.damage) / float(total_cost)
		if efficiency > 1.0:
			score *= 1.15
	
	# 命中率穩定加成
	if action.accuracy >= 85.0:
		score += 15.0
	
	return score

## 應用緊急狀況修正
func _apply_emergency_modifiers(base_score: float, action: Action, _character: Character, _opponent: Character, _battle_manager: BattleManager) -> float:
	var score = base_score
	
	# 只關注生存
	if "guard" in action.tags:
		return score + 100.0
	if "healing" in action.tags:
		return score + 90.0
	
	# 大幅懲罰攻擊動作
	if action.base_damage > 0:
		score *= 0.3
	
	return score

## 尋找帶有特定標籤的動作
func _find_action_with_tag(actions: Array, tag: String) -> Action:
	for action in actions:
		if tag in action.tags:
			return action
	return null

## 找到消耗最低的動作
func _find_lowest_cost_action(actions: Array) -> Action:
	if actions.size() == 0:
		return null
	
	var cheapest: Action = actions[0]
	var min_cost = cheapest.cost_stamina + cheapest.cost_mp
	
	for action in actions:
		var cost = action.cost_stamina + action.cost_mp
		if cost < min_cost:
			min_cost = cost
			cheapest = action
	
	return cheapest
