# DefensiveAI.gd
# 防守型 AI - 注重生存，優先防禦和恢復動作
extends AIBehavior
class_name DefensiveAI

# 低血量閾值
const LOW_HP_THRESHOLD = 0.3
const CRITICAL_HP_THRESHOLD = 0.15
const LOW_STA_THRESHOLD = 0.25

func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	if available_actions.size() == 0:
		return null
	
	# 過濾出可以使用的動作
	var affordable_actions = get_affordable_actions(available_actions, character, battle_manager)
	
	if affordable_actions.size() == 0:
		return _find_lowest_cost_action(available_actions)
	
	var hp_ratio = get_hp_ratio(character, battle_manager)
	var sta_ratio = get_sta_ratio(character, battle_manager)
	
	# 緊急狀況：極低血量時優先防禦
	if hp_ratio < CRITICAL_HP_THRESHOLD:
		var guard_action = _find_action_with_tag(affordable_actions, "guard")
		if guard_action:
			return guard_action
	
	# 低血量時尋找治療
	if hp_ratio < LOW_HP_THRESHOLD:
		var heal_action = _find_action_with_tag(affordable_actions, "healing")
		if heal_action:
			return heal_action
	
	# 低耐力時休息
	if sta_ratio < LOW_STA_THRESHOLD:
		var rest_action = _find_action_with_tag(affordable_actions, "rest")
		if rest_action:
			return rest_action
	
	# 評估所有動作，選擇最安全的
	var best_action: Action = null
	var best_score: float = -999999.0
	
	for action in affordable_actions:
		var score = evaluate_action(action, character, opponent, battle_manager)
		if score > best_score:
			best_score = score
			best_action = action
	
	return best_action

func evaluate_action(action: Action, character: Character, opponent: Character, battle_manager: BattleManager) -> float:
	var score: float = 0.0
	
	var hp_ratio = get_hp_ratio(character, battle_manager)
	var sta_ratio = get_sta_ratio(character, battle_manager)
	
	# 1. 優先低消耗動作
	score += (20.0 - action.cost_stamina) * 3.0
	score += (30.0 - action.cost_mp) * 2.0
	
	# 2. 高命中率加成（不想浪費資源）
	score += action.accuracy_modifier * 25.0
	
	# 3. 防禦和支援動作大幅加成
	if "guard" in action.tags:
		score += 40.0
		if hp_ratio < LOW_HP_THRESHOLD:
			score += 30.0  # 低血量時更重視防禦
	
	if "rest" in action.tags:
		if sta_ratio < LOW_STA_THRESHOLD:
			score += 50.0  # 低耐力時極度需要
		else:
			score += 20.0
	
	if "healing" in action.tags:
		if hp_ratio < LOW_HP_THRESHOLD:
			score += 60.0  # 低血量時優先治療
		else:
			score += 25.0
	
	if "support" in action.tags:
		score += 30.0
	
	# 4. 傷害適中即可（不是重點）
	score += action.base_damage * 5.0
	score += action.damage_multiplier * 8.0
	
	# 5. 狀態效果評估（偏好防禦性的）
	if action.status_effects.size() > 0:
		for effect_id in action.status_effects:
			if effect_id in ["regen"]:
				score += 25.0  # 再生很好
			elif effect_id in ["burning", "poison"]:
				score += 10.0  # 持續傷害還行
			elif effect_id == "weakness":
				score += 15.0  # 削弱敵人
	
	# 6. 懲罰高風險動作
	if action.accuracy_modifier < 0:
		score -= 30.0  # 不喜歡低命中率
	
	if "physical" in action.tags and action.base_damage > 15:
		score -= 10.0  # 高傷害通常高風險
	
	# 7. 血量越低越保守
	if hp_ratio < LOW_HP_THRESHOLD:
		if "guard" not in action.tags and "healing" not in action.tags:
			score *= 0.6  # 非防禦動作減分
	
	# 8. 對手血量低時可以稍微激進
	var opponent_hp_ratio = get_opponent_hp_ratio(opponent, battle_manager)
	if opponent_hp_ratio < 0.2:
		if action.base_damage > 0:
			score += 20.0  # 可以試著擊殺
	
	# 9. 添加小量隨機性
	score *= randf_range(0.95, 1.05)
	
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
