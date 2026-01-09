# AggressiveAI.gd
# 攻擊型 AI - 優先選擇高傷害動作，攻擊性強
extends AIBehavior
class_name AggressiveAI

func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	if available_actions.size() == 0:
		return null
	
	# 過濾出可以使用的動作
	var affordable_actions = get_affordable_actions(available_actions, character, battle_manager)
	
	if affordable_actions.size() == 0:
		# 如果沒有可用動作，嘗試找消耗最低的
		return _find_lowest_cost_action(available_actions)
	
	# 評估所有可用動作，選擇得分最高的
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
	
	# 1. 基礎傷害權重（最重要）
	score += action.damage * 15.0
	
	# 2. 命中率考量（固定命中率）
	score += action.accuracy * 0.5
	
	# 3. 攻擊性標籤加成
	if "physical" in action.tags:
		score += 20.0
	if "magic" in action.tags:
		score += 20.0
	if "ranged" in action.tags:
		score += 10.0  # 遠程稍微安全一點
	
	# 4. 暴擊率加成
	score += action.critical_rate * 10.0
	
	# 5. 狀態效果加成（能造成傷害的狀態更好）
	if action.effects_on_hit.size() > 0:
		for effect_id in action.effects_on_hit:
			if effect_id in ["burning", "poison"]:
				score += 15.0  # 持續傷害
			elif effect_id == "weakness":
				score += 10.0  # 降低敵人攻擊
	
	# 6. 擊倒加成（若會改變對手姿態為倒地）
	if action.target_stance_change_enabled and action.target_stance_change_to == Stance.Type.KNOCKED_DOWN:
		score += 30.0  # 擊倒非常有價值
	
	# 7. 低血量時稍微保守（但仍然攻擊導向）
	var hp_ratio = get_hp_ratio(character, battle_manager)
	if hp_ratio < 0.25:
		score *= 0.7  # 減少 30% 風險
	
	# 8. 對手低血量時更激進
	var opponent_hp_ratio = get_opponent_hp_ratio(opponent, battle_manager)
	if opponent_hp_ratio < 0.3:
		score *= 1.5  # 追擊加成
	
	# 9. 懲罰非攻擊性動作
	if "guard" in action.tags:
		score -= 50.0  # 不喜歡防禦
	if "rest" in action.tags:
		score -= 40.0  # 不喜歡休息
	if "healing" in action.tags:
		score -= 30.0  # 不喜歡治療
	
	# 11. 添加小量隨機性（避免太機械）
	score *= randf_range(0.95, 1.05)
	
	return score

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
